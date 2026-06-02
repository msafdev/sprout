//
//  CameraScreen.swift
//  Sprout
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraEngine()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageToPass: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Button(action: {
                    camera.isFlashOn.toggle()
                }) {
                    Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.6))
                        .clipShape(Circle())
                }
                .disabled(camera.capturedImage != nil)
                .opacity(camera.capturedImage != nil ? 0 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color.white)
            
            // Viewfinder / Preview Area
            ZStack(alignment: .bottom) {
                if let imageToPreview = camera.capturedImage {
                    GeometryReader { geometry in
                        Image(uiImage: imageToPreview)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                } else {
                    CameraPreviewContainer(session: camera.session)
                        .background(Color(.systemGray4))
                    
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 8) {
                            Text("upload your photo")
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Controls Bar
            HStack {
                if let verifiedImage = camera.capturedImage {
                    // Retake Button
                    Button(action: {
                        camera.capturedImage = nil
                        selectedItem = nil
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Retake")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // Use Photo Button
                    Button(action: {
                        imageToPass = verifiedImage
                    }) {
                        HStack {
                            Text("Use Photo")
                            Image(systemName: "checkmark")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                    }
                    
                } else {
                    // Control Row Buttons
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        camera.capturePhoto()
                    }) {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .padding(8)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        camera.flipCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            .padding(.bottom, 40)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: selectedItem) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        camera.capturedImage = image
                    }
                }
            }
        }
        .fullScreenCover(item: $imageToPass) { targetImage in
            EntryView(capturedImage: targetImage) {
                imageToPass = nil
                camera.capturedImage = nil
                selectedItem = nil
            }
        }
    }
}

// MARK: - LIVE FEED RENDER BRIDGE
struct CameraPreviewContainer: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIImage: Identifiable {
    public var id: String { UUID().uuidString }
}
