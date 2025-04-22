//
//  MainFoodItemView.swift
//  AINutritionist
//
//  Created by muser on 28.03.2025.
//

import SwiftUI

struct MainFoodItemView: View {
    @ObservedObject private var viewModel: MainFoodItemViewModel
    
    init(viewModel: MainFoodItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.time)
                .font(.custom("D-DIN-PRO-Regular", size: 16))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
            
            Text(viewModel.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-SemiBold", size: 16))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
            
            Text("\(viewModel.weight)")
                .font(.custom("D-DIN-PRO-Regular", size: 16))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
            
            Text("\(viewModel.calorie)")
                .font(.custom("D-DIN-PRO-Regular", size: 16))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
        }
        .padding(12)
        .background(Color.init(red: 245/255, green: 247/255, blue: 253/255))
        .cornerRadius(100)
    }
}

#Preview {
    MainFoodItemView(viewModel: .init(id: "", time: "", title: "", weight: "", calorie: ""))
}
