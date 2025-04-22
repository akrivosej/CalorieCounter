//
//  MainFoodItemViewModel.swift
//  AINutritionist
//
//  Created by muser on 28.03.2025.
//

import Foundation

final class MainFoodItemViewModel: ObservableObject, Hashable {
    @Published var id: String
    @Published var time: String
    @Published var title: String
    @Published var weight: String
    @Published var calorie: String
    
    init(id: String, time: String, title: String, weight: String, calorie: String) {
        self.id = id
        self.time = time
        self.title = title
        self.weight = weight
        self.calorie = calorie
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MainFoodItemViewModel, rhs: MainFoodItemViewModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.time == rhs.time &&
            lhs.title == rhs.title &&
            lhs.weight == rhs.weight &&
            lhs.calorie == rhs.calorie
    }
}
