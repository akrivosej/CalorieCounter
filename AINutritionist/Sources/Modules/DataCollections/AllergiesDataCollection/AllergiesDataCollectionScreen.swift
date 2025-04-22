//
//  AllergiesDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 25.03.2025.
//

import SwiftUI
import TelemetryDeck

struct AllergiesDataCollectionScreen: View {
    @State private var selectedOption: String? = nil
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 6)
                .padding(.top, 24)
            
            Text("Do you have any allergies?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .padding(.top, 24)
            
            DataCollectionAllergiesItem(text: "Yes (describe)", selectedOption: $selectedOption) {
                path.append(Router.allirgiesList)
            }
            .padding(.top, 24)
            DataCollectionAllergiesItem(text: "No", selectedOption: $selectedOption)
            
            Spacer()
            HStack(spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Image(.arrow)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                }
                
                Button {
                    if selectedOption != nil {
                        path.append(Router.fouthOnboadring)
                        UserDefaults.standard.set(selectedOption, forKey: "allergiesDataCollection")
                    }
                } label: {
                    Text("Next")
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.system(size: 28, weight: .medium, design: .default))
                }
                .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .cornerRadius(32)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("AllergiesDataCollectionScreen.load")
        }
    }
}

#Preview {
    AllergiesDataCollectionScreen(path: .constant(.init()))
}

struct DataCollectionAllergiesItem: View {
    let text: String
    @Binding var selectedOption: String?
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(text)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .font(.custom("D-DIN-PRO-Regular", size: 22))

            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(selectedOption == text
                    ? Color.init(red: 4/255, green: 212/255, blue: 132/255, opacity: 0.5)
                    : Color.white.opacity(0.001)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.init(red: 174/255, green: 174/255, blue: 174/255), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cornerRadius(12)
        .onTapGesture {
            selectedOption = text
            action?()
        }
        .animation(.easeInOut(duration: 0.2), value: selectedOption)
    }
}

