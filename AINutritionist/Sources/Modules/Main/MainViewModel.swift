//
//  MainViewModel.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import Foundation
import RealmSwift

//final class MainViewModel: ObservableObject {
//    @Published var items: [MainFoodItemViewModel]
//    @Published var water: Int = 0
//    @Published var kcal: Int = 0
//    @Published var maxWater: Int = 0
//    @Published var maxKcal: Int = 0
//    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
//
//    init(items: [MainFoodItemViewModel]) {
//        self.items = items
//    }
//    
//    func addDish(name: String, weight: String, kcal: String) {        
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else { return }
//        
//        let realm = try! Realm()
//        
//        try! realm.write {
//            let newDish = DailyRationDomainModel(
//                id: UUID(),
//                creationDate: Date(),
//                title: name,
//                calories: "\(kcal)cal",
//                weight: "\(weight)g"
//            )
//            
//            user.dailyRation.append(newDish)
//        }
//
//        loadData()
//    }
//    
//    func addWater(water: Int) {
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else { return }
//        
//        let realm = try! Realm()
//        
//        try! realm.write {
//            let newWater = DailyRationDomainModel(
//                id: UUID(),
//                creationDate: Date(),
//                title: "Water",
//                calories: "ml",
//                weight: "\(water)"
//            )
//            
//            user.dailyRation.append(newWater)
//        }
//
//        loadData()
//    }
//    
//    func loadData() {
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else { return }
//        
//        let filteredItems = user.dailyRation.filter {
//            Calendar.current.isDate($0.creationDate, inSameDayAs: self.selectedDate)
//        }
//
//        items = filteredItems.compactMap { makeCell(for: $0) }
//        
//        water = filteredItems
//            .filter { $0.title == "Water" }
//            .reduce(0) { $0 + (Int($1.weight) ?? 0) }
//        kcal = filteredItems.reduce(0) { $0 + (Int($1.calories) ?? 0) }
//        
//        maxKcal = Int(user.kklBalance)
//        maxKcal = Int(user.waterBalance)
//    }
//
//    
//    func makeCell(
//        for model: DailyRationDomainModel
//    ) -> MainFoodItemViewModel? {
//        return .init(
//            id: model.id.uuidString,
//            time: model.creationDate.formatted(date: .omitted, time: .shortened),
//            title: model.title,
//            weight: model.weight,
//            calorie: model.calories
//        )
//    }
//}

final class MainViewModel: ObservableObject {
    @Published var items: [MainFoodItemViewModel]
    @Published var water: Int = 0
    @Published var kcal: Int = 0
    @Published var maxWater: Int = 0
    @Published var maxKcal: Int = 0
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    init(items: [MainFoodItemViewModel]) {
        self.items = items
    }
    
    func addDish(name: String, weight: String, kcal: String) {
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else { return }
        
        let realm = try! Realm()
        
        try! realm.write {
            let newDish = DailyRationDomainModel(
                id: UUID(),
                creationDate: Date(),
                title: name,
                calories: kcal, // Store just the number without "cal"
                weight: weight  // Store just the number without "g"
            )
            
            user.dailyRation.append(newDish)
        }

        loadData()
    }
    
    func addWater(water: Int) {
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else { return }
        
        let realm = try! Realm()
        
        try! realm.write {
            let newWater = DailyRationDomainModel(
                id: UUID(),
                creationDate: Date(),
                title: "Water",
                calories: "0", // Water has no calories, so set to "0"
                weight: "\(water)"
            )
            
            user.dailyRation.append(newWater)
        }

        loadData()
    }
    
    func loadData() {
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else { return }
        
        let filteredItems = user.dailyRation.filter {
            Calendar.current.isDate($0.creationDate, inSameDayAs: self.selectedDate)
        }

        items = filteredItems.compactMap { makeCell(for: $0) }
        
        // Calculate total water amount
        water = filteredItems
            .filter { $0.title == "Water" }
            .reduce(0) { $0 + (Int($1.weight) ?? 0) }
        
        // Calculate total calories properly
        kcal = filteredItems
            .filter { $0.title != "Water" } // Exclude water items
            .reduce(0) { sum, item in
                // Extract the numeric part from calories
                let calorieValue = extractNumericValue(from: item.calories)
                return sum + calorieValue
            }
        
        // Correctly set maximum values
        maxKcal = Int(user.kklBalance)
        maxWater = Int(user.waterBalance)
    }
    
    // Helper function to extract numeric value from string
    private func extractNumericValue(from string: String) -> Int {
        let numericChars = CharacterSet.decimalDigits
        let numericString = string.filter { char in
            guard let scalar = char.unicodeScalars.first else { return false }
            return numericChars.contains(scalar)
        }
        return Int(numericString) ?? 0
    }
    
    func makeCell(
        for model: DailyRationDomainModel
    ) -> MainFoodItemViewModel? {
        // Format display values with appropriate units
        let formattedWeight = model.title == "Water" ? "\(model.weight)ml" : "\(model.weight)g"
        let formattedCalories = model.title == "Water" ? "" : "\(model.calories)cal"
        
        return .init(
            id: model.id.uuidString,
            time: model.creationDate.formatted(date: .omitted, time: .shortened),
            title: model.title,
            weight: formattedWeight,
            calorie: formattedCalories
        )
    }
}
