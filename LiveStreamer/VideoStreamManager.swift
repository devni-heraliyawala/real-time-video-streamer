//
//  VideoStreamManager.swift
//  LiveStreamer
//
//  Created by Devni Heraliyawala on 03/12/2024.
//

import AVFoundation
import UIKit

class VideoStreamManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sasUrl = "https://stitdbextdevuks.blob.core.windows.net/dbextqamt/test-video-stream-dev-ios-v2.mp4?sv=2025-01-05&st=2024-12-04T10%3A14%3A07Z&se=2024-12-08T14%3A14%3A07Z&sr=b&sp=acw&sig=fE7dZPYCsYDYeJjltO5Z5xF1A42l9L3uuzra4k9qmqA%3D"
    private let sessionQueue = DispatchQueue(label: "videoStreamSessionQueue")
    private let uploadQueue = DispatchQueue(label: "videoUploadQueue")
    private var isStreaming = false
    private var buffer = Data()
    private var lastProcessedTimestamp: CMTime = .zero

    @Published var captureSession = AVCaptureSession()
    @Published var isCameraAvailable = true

    func setupCamera() {
        captureSession.sessionPreset = .medium
        guard let camera = AVCaptureDevice.default(for: .video) else {
            isCameraAvailable = false
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            isCameraAvailable = false
            return
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
        if let output = videoOutput, captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
    }

    func startStreaming() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
        isStreaming = true
        
        // Create the Append Blob when starting the stream
        createAppendBlob()
    }

    func stopStreaming() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
        isStreaming = false
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isStreaming else { return }

        // Ensure frames are processed at consistent intervals (e.g., 1 frame per 0.1 seconds)
        let currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if currentTimestamp - lastProcessedTimestamp < CMTime(seconds: 0.1, preferredTimescale: 600) {
            return // Skip frame processing if the interval is too short
        }
        lastProcessedTimestamp = currentTimestamp

        // Process frame
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        
        guard let jpegData = uiImage.jpegData(compressionQuality: 0.5) else { return }
        buffer.append(jpegData)
        
        if buffer.count > 256 * 1024 { // Upload when the buffer exceeds 512 KB
            uploadBufferToAzure()
        }
    }

    private func createAppendBlob() {
        guard let url = URL(string: sasUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("AppendBlob", forHTTPHeaderField: "x-ms-blob-type")
        
        uploadQueue.async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to create AppendBlob: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Failed to create AppendBlob with response: \(response.debugDescription)")
                    return
                }
                
                print("Append Blob created successfully!")
            }
            task.resume()
        }
    }

    private func uploadBufferToAzure() {
        guard let url = URL(string: sasUrl + "&comp=appendblock") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let chunk = buffer
        buffer = Data() // Reset the buffer

        uploadQueue.async {
            let task = URLSession.shared.uploadTask(with: request, from: chunk) { data, response, error in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Failed to upload with response: \(response.debugDescription)")
                    return
                }
                
                print("Chunk uploaded successfully!")
            }
            task.resume()
        }
    }
}
