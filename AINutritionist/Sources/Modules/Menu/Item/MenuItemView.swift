//
//  MenuItemView.swift
//  AINutritionist
//
//  Created by muser on 02.04.2025.
//

import SwiftUI

struct MenuItemView: View {
    @ObservedObject private var viewModel: MenuItemViewModel
    var onTap: ((MenuItemViewModel) -> Void)?
    
    init(viewModel: MenuItemViewModel, onTap: ((MenuItemViewModel) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        HStack {
            if let uiImage = viewModel.getImage() {
                 Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(24)
             } else {
                 Image("")
                     .resizable()
                     .scaledToFit()
             }

            VStack {
                Text(viewModel.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Bold", size: 26))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                Spacer()
                Text("\(viewModel.calories) calories")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Regular", size: 18))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                Spacer()
            }
            
            
            Button {
                onTap?(viewModel)
            } label: {
                Text("Recipe")
                    .font(.custom("D-DIN-PRO-Medium", size: 20))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .background(Color.init(red: 255/255, green: 184/255, blue: 84/255))
            .cornerRadius(18)
        }
    }
}

#Preview {
    MenuItemView(viewModel: .init(id: "1", image: "test", title: "123", calories: "asd", ingredients: [], description: "asd"))
}
