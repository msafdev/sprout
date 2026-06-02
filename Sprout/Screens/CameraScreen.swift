//
//  CameraScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 28/05/26.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraScreen: View {
    @Binding var selectedTab: Int
    @StateObject private var camera = CameraEngine()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageToPass: CameraScreenImage? = nil
    
    @State private var flashPulse = false
    @State private var showGrid = false
    @State private var timerActive = false
    @State private var timerCount = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    Group {
                        if let imageToPreview = camera.capturedImage {
                            Image(uiImage: imageToPreview)
                                .resizable()
                                .scaledToFill()
                        } else {
                            CameraPreviewContainer(session: camera.session)
                        }
                        
                        if showGrid {
                            GridOverlay()
                        }
                    }
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 440 * 3/4))
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color(.opaqueSeparator).opacity(0.35), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 72)
                    
                    VStack {
                        HStack {
                            Button(action: { selectedTab = 0 }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.primary.opacity(0.24))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                    camera.isFlashOn.toggle()
                                    flashPulse = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        flashPulse = false
                                    }
                                }
                            }) {
                                Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(camera.isFlashOn ? .black : .white)
                                    .frame(width: 44, height: 44)
                                    .background(camera.isFlashOn ? Color.yellow : Color.primary.opacity(0.24))
                                    .clipShape(Circle())
                                    .scaleEffect(flashPulse ? 1.1 : 1)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                if camera.capturedImage == nil {
                    VStack(spacing: 32) {
                        HStack(spacing: 16) {
                            cameraOptionButton(icon: "rectangle.grid.3x3", active: showGrid) {
                                showGrid.toggle()
                            }
                            cameraOptionButton(icon: "clock", active: timerActive) {
                                timerActive.toggle()
                            }
                        }
                        
                        HStack(spacing: 48) {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Button(action: {
                                if timerActive {
                                    startTimer()
                                } else {
                                    camera.capturePhoto()
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .frame(width: 64, height: 64)
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color(red: 150/255, green: 180/255, blue: 80/255), lineWidth: 4)
                                        .frame(width: 62, height: 62)
                                    if timerCount > 0 {
                                        Text("\(timerCount)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(red: 150/255, green: 180/255, blue: 80/255))
                                    } else {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color(red: 150/255, green: 180/255, blue: 80/255))
                                            .frame(width: 48, height: 48)
                                    }
                                }
                            }
                            .disabled(timerCount > 0)
                            
                            Button(action: { camera.flipCamera() }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.blue.opacity(0.85))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                } else {
                    VStack(spacing: 48) {
                        // Image info section
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 150/255, green: 180/255, blue: 80/255))
                            
                            Text("Photo captured")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // Retake button
                            Button(action: {
                                camera.capturedImage = nil
                                selectedItem = nil
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Retake")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                            }
                            
                            // Use Photo button
                            Button(action: {
                                if let verifiedImage = camera.capturedImage {
                                    imageToPass = CameraScreenImage(image: verifiedImage)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Use Photo")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 150/255, green: 180/255, blue: 80/255))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 64)
                }
            }
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
        .fullScreenCover(item: $imageToPass) { target in
            EntryView(capturedImage: target.image) {
                imageToPass = nil
                camera.capturedImage = nil
                selectedItem = nil
            }
        }
    }
    
    @ViewBuilder
    private func cameraOptionButton(icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(active ? Color(.systemGray5) : Color(.systemGray6))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(active ? .primary : .secondary)
            }
        }
    }
    
    private func startTimer() {
        timerCount = 3
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            timerCount -= 1
            if timerCount <= 0 {
                t.invalidate()
                camera.capturePhoto()
                timerActive = false
                timerCount = 0
            }
        }
    }
    
    private struct GridOverlay: View {
        var body: some View {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let lineWidth: CGFloat = 1
                Path { path in
                    let col1 = width / 3
                    let col2 = width * 2 / 3
                    let row1 = height / 3
                    let row2 = height * 2 / 3
                    path.move(to: CGPoint(x: col1, y: 0))
                    path.addLine(to: CGPoint(x: col1, y: height))
                    path.move(to: CGPoint(x: col2, y: 0))
                    path.addLine(to: CGPoint(x: col2, y: height))
                    path.move(to: CGPoint(x: 0, y: row1))
                    path.addLine(to: CGPoint(x: width, y: row1))
                    path.move(to: CGPoint(x: 0, y: row2))
                    path.addLine(to: CGPoint(x: width, y: row2))
                }
                .stroke(Color.white.opacity(0.65), lineWidth: lineWidth)
            }
            .allowsHitTesting(false)
        }
    }
}

private struct CameraScreenImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - LIVE FEED RENDER BRIDGE
struct CameraPreviewContainer: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
