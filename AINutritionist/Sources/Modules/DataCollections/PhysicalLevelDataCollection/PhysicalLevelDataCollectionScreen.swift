//
//  PhysicalLevelDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI
import TelemetryDeck

struct PhysicalLevelDataCollectionScreen: View {
    @State private var selectedOption: String? = nil
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 4)
                .padding(.top, 24)
            
            Text("Your level of physical fitness")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .padding(.top, 24)
//            Spacer()
            DataCollectionItem(image: "physicalLevelIconEasy", text: "I'm not doing anything", selectedOption: $selectedOption)
                .padding(.top, 24)
            DataCollectionItem(image: "physicalLevelIconMedium", text: "I do from time to time", selectedOption: $selectedOption)
            DataCollectionItem(image: "physicalLevelIconHard", text: "Active lifestyle", selectedOption: $selectedOption)
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
                        path.append(Router.thirdOnboarding)
                        UserDefaults.standard.set(selectedOption, forKey: "physicalLevelDataCollection")
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
            TelemetryDeck.signal("PhysicalLevelDataCollectionScreen.load")
        }
    }
}

#Preview {
    PhysicalLevelDataCollectionScreen(path: .constant(.init()))
}
