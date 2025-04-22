//
//  AllirgiesListScreen.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import SwiftUI

struct AllirgiesListScreen: View {
    @State private var longText: String = ""
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
//            Spacer()
            
            TextEditor(text: $longText)
                .font(.custom("D-DIN-PRO-Regular", size: 24))
                .foregroundStyle(Color.init(red: 102/255, green: 102/255, blue: 102/255))
                .frame(height: 200)
                .cornerRadius(24)
                .padding(.top, 24)
            
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
                    UserDefaults.standard.set(longText, forKey: "allirgiesListScreen")
                    path.append(Router.fouthOnboadring)
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
    }
}

#Preview {
    AllirgiesListScreen(path: .constant(.init()))
}
