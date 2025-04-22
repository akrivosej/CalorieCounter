//
//  CameraScreen.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import SwiftUI

struct CameraScreen: View {
    @ObservedObject var cameraViewModel = CameraViewModel()
    @Binding var isPresented: Bool
    var onPhotoTaken: ((String, String, String) -> Void)?
    
    var body: some View {
        ZStack {
            if let session = cameraViewModel.session {
                CameraPreview(session: session)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Camera error")
                    .foregroundColor(.white)
            }
            
            if cameraViewModel.isProcessingImage {
                ProgressView("Анализирую блюдо...")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let image = cameraViewModel.capturedImage {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    
                    if let foodInfo = cameraViewModel.recognizedFood {
                        VStack(spacing: 10) {
                            Text("Found: \(foodInfo.name)")
                                .font(.headline)
                            
                            Text("Calories: \(foodInfo.calories) kcal")
                            Text("Weight: \(foodInfo.weight) g")
                            
                            HStack {
                                Button("Cancel") {
                                    cameraViewModel.capturedImage = nil
                                    cameraViewModel.recognizedFood = nil
                                }
                                .padding()
                                .background(Color.red)
                                .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                                .cornerRadius(32)
                                
                                Button("Confirm") {
                                    if let food = cameraViewModel.recognizedFood {
                                        onPhotoTaken?(food.name, food.weight, food.calories)
                                        isPresented = false
                                    }
                                }
                                .padding()
                                .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                                .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                                .cornerRadius(32)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            cameraViewModel.takePhoto()
                        }) {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}


//struct CameraScreen: View {
//    @ObservedObject var cameraViewModel = CameraViewModel()
//    @Binding var isPresented: Bool
//    var onPhotoTaken: ((UIImage) -> Void)?
//
//    var body: some View {
//        ZStack {
//            if let session = cameraViewModel.session {
//                CameraPreview(session: session)
//                    .edgesIgnoringSafeArea(.all)
//            } else {
//                Text("Camera error")
//                    .foregroundColor(.white)
//            }
//
//            VStack {
//                Spacer()
//                HStack {
//                    Button(action: {
//                        isPresented = false
//                    }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                    .padding()
//
//                    Spacer()
//
//                    Button(action: {
//                        cameraViewModel.takePhoto()
//                    }) {
//                        Image(systemName: "camera.circle.fill")
//                            .resizable()
//                            .frame(width: 70, height: 70)
//                            .foregroundColor(.white)
//                    }
//                    .padding()
//                }
//            }
//        }
//        .onAppear {
//            cameraViewModel.startSession()
//        }
//        .onDisappear {
//            cameraViewModel.stopSession()
//        }
//        .onChange(of: cameraViewModel.capturedImage) { newImage in
//            if let image = newImage {
//                onPhotoTaken?(image)
//                isPresented = false
//            }
//        }
//    }
//}


