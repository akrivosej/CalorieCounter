//
//  DataCollectionItem.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import Foundation
import SwiftUI

struct DataCollectionItem: View {
    let image: String
    let text: String
//    let category: Category
    @Binding var selectedOption: String?
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text(text)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .font(.custom("D-DIN-PRO-Regular", size: 22))
            
            Spacer()
        }
        .padding(.horizontal, 12)
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
        }
        .animation(.easeInOut(duration: 0.2), value: selectedOption)
    }
}
