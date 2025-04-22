//
//  AddWaterView.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import SwiftUI

struct AddWaterView: View {
    @State private var water: Int = 100
    @State private var selectedTime = Date()
    @State private var showPicker = false
    var onTap: (() -> Void)?
    var onConfirmTap: ((Int) -> Void)?
    
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
                Text("Add a water")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.custom("D-DIN-PRO-SemiBold", size: 36))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    .padding(.top, 32)
                
                VStack {
                    Text("Amount of water")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-Regular", size: 22))
                        .foregroundStyle(Color.init(red: 102/255, green: 102/255, blue: 102/255))
                        .padding(.bottom, 8)
                    HStack {
                        Button {
                            if water > 0 {
                                water -= 100
                            }
                        } label: {
                            Text("-")
                                .font(.custom("D-DIN-PRO-Regular", size: 52))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 27)
                                .padding(.vertical, 24)
                        }
                        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                        .cornerRadius(24)
                        
                        Text("\(water)")
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Regular", size: 36))
                            .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(red: 235/255, green: 243/255, blue: 241/255))
                                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                            )
                            .padding(.horizontal, 4)
                        
                        Button {
                            if water < 3000 {
                                water += 100
                            }
                        } label: {
                            Text("+")
                                .font(.custom("D-DIN-PRO-Regular", size: 52))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)
                        }
                        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                        .cornerRadius(24)
                    }
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.init(red: 178/255, green: 178/255, blue: 178/255), lineWidth: 1)
                )
                .padding(12)
                
                VStack {
                    Text("Select a time")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-Regular", size: 22))
                        .foregroundStyle(Color.init(red: 102/255, green: 102/255, blue: 102/255))
                        .padding(.bottom, 8)
                    
                    Text(timeFormatted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-Regular", size: 52))
                        .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                        .padding(.bottom, 8)
                        .onTapGesture {
                            withAnimation {
                                showPicker.toggle()
                            }
                        }
                    
                    if showPicker {
                        DatePicker("", selection: $selectedTime, in: ...Date(), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .transition(.opacity)
                    }
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.init(red: 178/255, green: 178/255, blue: 178/255), lineWidth: 1)
                )
                .padding(12)
                
                Button {
                    onConfirmTap?(water)
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

        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 34/255, green: 34/255, blue: 34/255, opacity: 0.6))
    }
    
    private var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    AddWaterView()
}
