//
//  MenuDetailsView.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import SwiftUI

struct MenuDetailsView: View {
    @ObservedObject private var viewModel: MenuDetailsViewModel
    var onTap: (() -> Void)?
    
    init(viewModel: MenuDetailsViewModel, onTap: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onTap = onTap
    }
    
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
            ScrollView {
                VStack {
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
                            //                            .padding(.vertical, 18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("D-DIN-PRO-Bold", size: 32))
                                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                            
                            Text("\(viewModel.calories) calories")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("D-DIN-PRO-Regular", size: 20))
                                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        }
                    }
                    Text("Ingredients:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(viewModel.ingredients, id: \.self) { item in
                            Text(item)
                                .font(.custom("D-DIN-PRO-Regular", size: 16))
                                .foregroundColor(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                                .padding(8)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.init(red: 178/255, green: 178/255, blue: 178/255), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                    }

                    Text("Preparation:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    
                    Text(viewModel.description)
                        .font(.custom("D-DIN-PRO-Regular", size: 20))
                        .foregroundColor(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        .padding(.top, 12)
                }
            }
            .scrollIndicators(.hidden)
            .padding(18)
            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
            .cornerRadius(32)
        }
        .padding(.vertical, 102)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 34/255, green: 34/255, blue: 34/255, opacity: 0.6))
    }
}

#Preview {
    MenuDetailsView(viewModel: .init(id: "1", image: "test", title: "Greek salad", calories: "200 calories", ingredients: [
        "3 tomatoes",
        "1 cucumber",
        "1 tsp lemon juice or wine vinegar"
    ], description: "Cut the tomatoes into large pieces, and slice the cucumber into rounds or half-moons. \nRemove the seeds from the bell pepper and slice it into strips. \nSlice the onion into thin half-rings. \nCut the feta into cubes or crumble it by hand. \nIn a large bowl, mix the vegetables and add the olives. \nDrizzle with olive oil, add lemon juice, and season with oregano, salt, and pepper. \nGently toss and serve!"))
}
