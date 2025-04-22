//
//  MenuScreen.swift
//  AINutritionist
//
//  Created by muser on 24.03.2025.
//

import SwiftUI
import TelemetryDeck

struct MenuScreen: View {
    @ObservedObject private var viewModel: MenuViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @State private var isSelected = true
    @State private var selectedItem: MenuItemViewModel? = nil
    
    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    
    init(viewModel: MenuViewModel, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomSwitcher(isSelected: $isSelected)
                
                Text(todayDate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Regular", size: 42))
                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                
                ScrollView {
                    VStack(spacing: 20) {
                        if !viewModel.breakfastItems.isEmpty {
                            mealSection(title: "Breakfast", items: viewModel.breakfastItems)
                        }
                        
                        if !viewModel.lunchItems.isEmpty {
                            mealSection(title: "Lunch", items: viewModel.lunchItems)
                        }
                        
                        if !viewModel.dinnerItems.isEmpty {
                            mealSection(title: "Dinner", items: viewModel.dinnerItems)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)
            .background(Color(red: 235/255, green: 243/255, blue: 241/255))
            .onAppear {
                viewModel.loadData()
            }
            
            if let selectedItem = selectedItem {
                MenuDetailsView(viewModel: .init(
                    id: selectedItem.id,
                    image: selectedItem.image,
                    title: selectedItem.title,
                    calories: selectedItem.calories,
                    ingredients: selectedItem.ingredients,
                    description: selectedItem.description
                )) {
                    self.selectedItem = nil
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: selectedItem)
        .onAppear {
            TelemetryDeck.signal("MenuScreen.load")
        }
    }
    
    private func mealSection(title: String, items: [MenuItemViewModel]) -> some View {
        VStack {
            Text(title)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(red: 138/255, green: 138/255, blue: 138/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color(red: 174/255, green: 174/255, blue: 174/255), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(4)
                .padding(.bottom, 8)
            
            VStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    MenuItemView(viewModel: item) { menuItem in
                        selectedItem = menuItem
                    }
                    .frame(height: 80)
                    .padding(4)
                }
            }
        }
        .background(.white)
        .cornerRadius(24)
    }
}



//struct MenuScreen: View {
//    @ObservedObject private var viewModel: MenuViewModel
//    @Binding var path: NavigationPath
//    @Environment(\.dismiss) var dismiss
//    @State private var isSelected = true
//    @State private var selectedItem: MenuItemViewModel? = nil
//    
//    private var todayDate: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM d"
//        return formatter.string(from: Date())
//    }
//    
//    init(viewModel: MenuViewModel, path: Binding<NavigationPath>) {
//        self.viewModel = viewModel
//        self._path = path
//    }
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                CustomSwitcher(isSelected: $isSelected)
//                
//                Text(todayDate)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.custom("D-DIN-PRO-Regular", size: 42))
//                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
//                
//                ScrollView {
//                    VStack {
//                        Text("Breakfast")
//                            .padding(.vertical, 6)
//                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(Color(red: 138/255, green: 138/255, blue: 138/255))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 100)
//                                    .stroke(Color(red: 174/255, green: 174/255, blue: 174/255), lineWidth: 1)
//                            )
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .padding(.bottom, 12)
//                        
//                        ForEach(viewModel.items, id: \.self) { item in
//                            MenuItemView(viewModel: item) { menuItem in
//                                selectedItem = menuItem
//                            }
//                            .frame(height: 80)
//                        }
//                    }
//                    .padding(12)
//                    .background(.white)
//                    .cornerRadius(24)
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal, 18)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 235/255, green: 243/255, blue: 241/255))
//            .onAppear {
//                viewModel.loadData()
//            }
//            
//            if let selectedItem = selectedItem {
//                MenuDetailsView(viewModel: .init(id: selectedItem.id, image: selectedItem.image, title: selectedItem.title, calories: selectedItem.calories, ingredients: selectedItem.ingredients, description: selectedItem.description)) {
//                    self.selectedItem = nil
//                }
//                .transition(.opacity)
//            }
//        }
//        .animation(.easeInOut, value: selectedItem)
//    }
//}


#Preview {
    MenuScreen(viewModel: .init(), path: .constant(.init()))
}


struct CustomSwitcher: View {
    @Binding var isSelected: Bool
    let options = ["AI generated", "Custom"]

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.init(red: 255/255, green: 255/255, blue: 255/255))
                .frame(height: 70)
            
            HStack {
                if !isSelected {
                    Spacer()
                }
                
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                    .frame(width: UIScreen.main.bounds.width / 2.4, height: 70)
                
                if isSelected {
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isSelected)

            HStack {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation {
                            isSelected = (option == "AI generated")
                        }
                    }) {
                        Text(option)
                            .font(.custom("D-DIN-PRO-Bold", size: 22))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(isSelected == (option == "AI generated")
                                             ? Color.init(red: 235/255, green: 243/255, blue: 241/255)
                                             : Color.init(red: 86/255, green: 86/255, blue: 86/255)
                            )
                    }
                }
            }
        }
//        .padding(.horizontal, 24)
    }
}
