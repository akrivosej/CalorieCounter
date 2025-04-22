//
//  FoodPreferencesDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI
import TelemetryDeck

struct FoodPreferencesDataCollectionScreen: View {
    @State private var selectedOption: String? = nil
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 5)
                .padding(.top, 24)
            
            Text("What is your favorite type of food")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .padding(.top, 24)
//            Spacer()
            DataCollectionItem(image: "meatIcon", text: "Meat", selectedOption: $selectedOption)
                .padding(.top, 24)
            DataCollectionItem(image: "fishIcon", text: "Fish", selectedOption: $selectedOption)
            DataCollectionItem(image: "vegetablesIcon", text: "Vegetables", selectedOption: $selectedOption)
            DataCollectionItem(image: "veganIcon", text: "Vegan", selectedOption: $selectedOption)
            DataCollectionItem(image: "otherIcon", text: "Other", selectedOption: $selectedOption)
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
                        path.append(Router.allergiesDataCollection)
                        UserDefaults.standard.set(selectedOption, forKey: "foodPreferencesDataCollection")
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
            TelemetryDeck.signal("FoodPreferencesDataCollectionScreen.load")
        }
    }
}

#Preview {
    FoodPreferencesDataCollectionScreen(path: .constant(.init()))
}
