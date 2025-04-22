//
//  CameraManager.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import AVFoundation
import UIKit

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Камера недоступна")
            return
        }

        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)
        captureSession.startRunning()
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }

    func getSession() -> AVCaptureSession {
        return captureSession
    }
}

