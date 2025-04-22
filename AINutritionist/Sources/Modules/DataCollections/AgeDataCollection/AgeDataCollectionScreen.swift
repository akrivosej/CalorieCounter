//
//  AgeDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 18.03.2025.
//

import SwiftUI
import TelemetryDeck

struct AgeDataCollectionScreen: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    @State private var age: Int = 18
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 3)
                .padding(.top, 24)
            
            Text("Set your age")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                .padding(.top, 24)
            
            Text("We need this information to choose best diet for you")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Regular", size: 26))
                .foregroundStyle(Color(red: 104/255, green: 104/255, blue: 104/255))
                .padding(.top, 2)
            
            Spacer()
            
            HStack {
                Button {
                    if age > 18 {
                        age -= 1
                    }
                } label: {
                    Text("-")
                        .font(.custom("D-DIN-PRO-Regular", size: 76))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 38)
                }
                .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                .cornerRadius(24)
                
                Text("\(age)")
                    .frame(maxWidth: .infinity)
                    .font(.custom("D-DIN-PRO-Regular", size: 76))
                    .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 235/255, green: 243/255, blue: 241/255))
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                    )
                    .padding(.horizontal, 4)
                
                Button {
                    if age < 80 {
                        age += 1
                    }
                } label: {
                    Text("+")
                        .font(.custom("D-DIN-PRO-Regular", size: 76))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 38)
                }
                .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                .cornerRadius(24)
            }
            
            Spacer()
            
            HStack(spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Image(.arrow)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                }
                
                Button {
                    path.append(Router.physicalLevelDataCollection)
                    UserDefaults.standard.set(age, forKey: "ageDataCollection")
                } label: {
                    Text("Next")
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color(red: 235/255, green: 243/255, blue: 241/255))
                }
                .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                .cornerRadius(32)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("AgeDataCollectionScreen.load")
        }
    }
}

#Preview {
    AgeDataCollectionScreen(path: .constant(.init()))
}
