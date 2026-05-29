//
//  CameraTools.swift
//  Sprout
//
//  Created by Gusti Sandyaga Putra Wardhana on 28/05/26.
//

import AVFoundation
import SwiftUI
import PhotosUI
import Combine

// MARK: - THE CAMERA CONTROLLER (THE BRAIN)
class CameraEngine: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isFlashOn: Bool = false
    @Published var capturedImage: UIImage? = nil
    
    private let photoOutput = AVCapturePhotoOutput()
    private var activeInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let defaultDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: defaultDevice) else {
            print("Failed to initialize default back camera")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            self.activeInput = input
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(.on) {
            settings.flashMode = isFlashOn ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func flipCamera() {
        session.beginConfiguration()
        guard let currentInput = activeInput else { return }
        session.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            session.addInput(currentInput)
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            self.activeInput = newInput
        } else {
            session.addInput(currentInput)
        }
        
        session.commitConfiguration()
    }
}

// Delegate protocol updating our published property
extension CameraEngine: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo details: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

