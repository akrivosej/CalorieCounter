//
//  ThirdOnboardingScreen.swift
//  AINutritionist
//
//  Created by muser on 18.03.2025.
//

import SwiftUI
import TelemetryDeck

struct ThirdOnboardingScreen: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            Text("With us, you'll learn how to take care of")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Regular", size: 32))
                .foregroundStyle(Color.init(red: 66/255, green: 66/255, blue: 66/255))
            Text("a beautiful body")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Heavy", size: 42))
                .textCase(.uppercase)
                .foregroundStyle(Color.init(red: 0/255, green: 219/255, blue: 91/255))
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
                    path.append(Router.foodPreferencesDataCollection)
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
        .background(
            Image(.thirdOnbBackground)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2)
        )
        .onAppear {
            TelemetryDeck.signal("ThirdOnboardingScreen.load")
        }
    }
}

#Preview {
    ThirdOnboardingScreen(path: .constant(.init()))
}
