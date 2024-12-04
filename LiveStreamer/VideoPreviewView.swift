//
//  VideoPreviewView.swift
//  LiveStreamer
//
//  Created by Devni Heraliyawala on 03/12/2024.
//


//
//  VideoPreviewView.swift
//  TestApp1
//
//  Created by Devni Heraliyawala on 03/12/2024.
//


import SwiftUI
import AVFoundation

struct VideoPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
