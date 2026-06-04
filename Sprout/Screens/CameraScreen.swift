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
    @State private var timerActive = false
    @State private var timerCount = 0
    
    var body: some View {
        ZStack {
            AppGradientBackground()
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
                    }
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 440 * 3/4))
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: [Color.fromHex("#1F2421"), Color.fromHex("#0F1110")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 12) {
                                Image(systemName: "camera.aperture")
                                    .font(.system(size: 48, weight: .thin))
                                    .foregroundColor(Color.appAccent.opacity(0.8))
                                    .scaleEffect(1.0)
                                    .padding(.bottom, 4)

                                Text("Camera view finder")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))

                                Text("Point at your sprout or lesson activity")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                    )
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
                    VStack(spacing: 21) {
                        // 1. Conditional visibility: The text only exists in the UI tree when active
                        if timerActive {
                            Text("3-second timer is active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .transition(.opacity.combined(with: .move(edge: .top))) // Smooth entrance
                        }
                        HStack(spacing: 16) {
                            cameraOptionButton(icon: "clock", active: timerActive) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    timerActive.toggle()
                                }
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
                                        .stroke(Color.appAccent, lineWidth: 4)
                                        .frame(width: 62, height: 62)
                                    if timerCount > 0 {
                                        Text("\(timerCount)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color.appAccent)
                                    } else {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.appAccent)
                                            .frame(width: 48, height: 48)
                                    }
                                }
                            }
                            .disabled(timerCount > 0)
                            
                            Button(action: { camera.flipCamera() }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                } else {
                    VStack(spacing: 48) {
                        
                        HStack(spacing: 12) {
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
            // Fixed: Passing selectedTab binding parameters cleanly to match setup
            EntryView(capturedImage: target.image, selectedTab: $selectedTab) {
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
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            DispatchQueue.main.async {
                self.timerCount -= 1
                if self.timerCount <= 0 {
                    t.invalidate()
                    self.camera.capturePhoto()
                    self.timerActive = false
                    self.timerCount = 0
                }
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

struct CameraPreviewContainer: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {}
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
