//
//  CameraPreview.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    var session: AVCaptureSession?

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(previewLayer)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


