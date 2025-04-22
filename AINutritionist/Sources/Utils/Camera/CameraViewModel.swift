//
//  CameraViewModel.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import Foundation
import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    @Published var isCameraActive = false
    @Published var recognizedFood: (name: String, calories: String, weight: String)?
    @Published var isProcessingImage = false
    
    private var captureSession: AVCaptureSession?
    private var photoOutput = AVCapturePhotoOutput()
    private let foodAnalyzer = FoodImageAnalyzer()

    override init() {
        super.init()
        setupCamera()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.isProcessingImage = true
            
            // Анализируем изображение
            self.foodAnalyzer.analyzeFoodImage(image: image) { foodName, calories, weight in
                self.recognizedFood = (name: foodName, calories: calories, weight: weight)
                self.isProcessingImage = false
            }
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Ошибка доступа к камере")
            return
        }

        captureSession?.addInput(input)
        captureSession?.addOutput(photoOutput)
    }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    var session: AVCaptureSession? {
        return captureSession
    }
}

