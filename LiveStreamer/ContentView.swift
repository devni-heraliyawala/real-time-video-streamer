//
//  ContentView.swift
//  LiveStreamer
//
//  Created by Devni Heraliyawala on 03/12/2024.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var videoStreamManager = VideoStreamManager()
        
        var body: some View {
            VStack {
                Text("Live Video Stream to Azure Blob Storage")
                    .font(.headline)
                    .padding()
                
                if videoStreamManager.isCameraAvailable {
                    VideoPreviewView(session: videoStreamManager.captureSession)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Text("Camera not available")
                        .foregroundColor(.red)
                }
                
                HStack {
                    Button(action: {
                        videoStreamManager.startStreaming()
                    }) {
                        Text("Start Streaming")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        videoStreamManager.stopStreaming()
                    }) {
                        Text("Stop Streaming")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .onAppear {
                videoStreamManager.setupCamera()
            }
        }
    }

    // Preview for SwiftUI
    #Preview {
        ContentView()
    }
