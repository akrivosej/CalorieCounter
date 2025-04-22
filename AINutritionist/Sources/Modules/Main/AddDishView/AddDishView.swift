//
//  AddDishView.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import SwiftUI

struct AddDishView: View {
    @State private var name = ""
    @State private var weight = ""
    @State private var kcal = ""
    var onTap: (() -> Void)?
    var onConfirmTap: ((String, String, String) -> Void)?
    var onPhotoTaken: (() -> Void)?

    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                onTap?()
            } label: {
                Image(.closeButton)
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 50, height: 50, alignment: .trailing)
            
            VStack {
                Text("Add a dish")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.custom("D-DIN-PRO-SemiBold", size: 36))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    .padding(.top, 32)
                
                TextField("", text: $name, prompt: Text("Dish name").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                    .font(.custom("D-DIN-PRO-Regular", size: 22))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .padding(.vertical, 2)
                    .foregroundColor(.black)
                    .tint(.black)
                    .background {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                
                TextField("", text: $weight, prompt: Text("Weight").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                    .font(.custom("D-DIN-PRO-Regular", size: 22))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .padding()
                    .padding(.vertical, 2)
                    .foregroundColor(.black)
                    .tint(.black)
                    .background {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal, 18)
                
                TextField("", text: $kcal, prompt: Text("Kcal").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                    .font(.custom("D-DIN-PRO-Regular", size: 22))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .padding()
                    .padding(.vertical, 2)
                    .foregroundColor(.black)
                    .tint(.black)
                    .background {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal, 18)
                
                Button {
                    onConfirmTap?(name, weight, kcal)
                } label: {
                    Text("Confirm")
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.system(size: 28, weight: .medium, design: .default))
                }
                .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                .cornerRadius(32)
                .padding(18)
            }
            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
            .cornerRadius(32)
            
            Text("or")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.custom("D-DIN-PRO-Regular", size: 36))
                .foregroundStyle(.white)
//                .padding(.top, 32)
            
            Button {
                isCameraPresented = true
            } label: {
                HStack {
                    Text("Camera on")
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 32))
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.system(size: 28, weight: .medium, design: .default))

                    Image(.cameraIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 60, height: 60)
                }
            }
            .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
            .cornerRadius(32)

        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 34/255, green: 34/255, blue: 34/255, opacity: 0.6))
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraScreen(isPresented: $isCameraPresented) { foodName, foodWeight, calories in
                // Автоматически заполняем форму распознанными данными
                name = foodName
                weight = foodWeight
                kcal = calories
            }
        }
    }
}

#Preview {
    AddDishView()
}
