//
//  MenuViewModel.swift
//  AINutritionist
//
//  Created by muser on 02.04.2025.
//

import Foundation
import UIKit

//final class MenuViewModel: ObservableObject {
//    @Published var breakfastItems: [MenuItemViewModel] = []
//    @Published var lunchItems: [MenuItemViewModel] = []
//    @Published var dinnerItems: [MenuItemViewModel] = []
//    
//    init() {
//        
//    }
//    
//    func loadData() {
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else { return }
//    
//        breakfastItems = []
//        lunchItems = []
//        dinnerItems = []
//        
//        for item in user.dailyPrescriptionRation {
//            if let menuItem = makeCell(for: item) {
//                switch item.mealType {
//                case "Завтрак":
//                    breakfastItems.append(menuItem)
//                case "Обед":
//                    lunchItems.append(menuItem)
//                case "Ужин":
//                    dinnerItems.append(menuItem)
//                default:
//                    break
//                }
//            }
//        }
//    }
//        
//    func makeCell(
//        for model: DailyPrescriptionRationDomainModel
//    ) -> MenuItemViewModel? {
//        return .init(
//            id: model.id.uuidString,
//            image: "test",
//            title: model.title,
//            calories: "\(model.calories)",
//            ingredients: model.ingredients.map { $0.value },
//            description: model.preparation
//        )
//    }
//}

final class MenuViewModel: ObservableObject {
    @Published var breakfastItems: [MenuItemViewModel] = []
    @Published var lunchItems: [MenuItemViewModel] = []
    @Published var dinnerItems: [MenuItemViewModel] = []
    
    init() {
        
    }
    
    func loadData() {
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else { return }
    
        breakfastItems = []
        lunchItems = []
        dinnerItems = []
        
        for item in user.dailyPrescriptionRation {
            if let menuItem = makeCell(for: item) {
                // Updated to handle English meal types
                switch item.mealType {
                case "Breakfast", "BREAKFAST", "Завтрак", "ЗАВТРАК":
                    breakfastItems.append(menuItem)
                case "Lunch", "LUNCH", "Обед", "ОБЕД":
                    lunchItems.append(menuItem)
                case "Dinner", "DINNER", "Ужин", "УЖИН":
                    dinnerItems.append(menuItem)
                default:
                    print("Unknown meal type: \(item.mealType)")
                    break
                }
            }
        }
    }
        
    func makeCell(
        for model: DailyPrescriptionRationDomainModel
    ) -> MenuItemViewModel? {
        var imageResource = "test" // Default value
        
        if let imageData = model.imageData {
            if let uiImage = UIImage(data: imageData) {
                // Option 1: Save image temporarily and use file name
                let imageName = "meal_\(model.id.uuidString)"
                saveImageToDisk(uiImage, withName: imageName)
                imageResource = imageName
            }
        }
        
        return .init(
            id: model.id.uuidString,
            image: imageResource,
            title: model.title,
            calories: "\(model.calories)",
            ingredients: model.ingredients.map { $0.value },
            description: model.preparation
        )
    }
    
    // Helper function to save image to disk
    private func saveImageToDisk(_ image: UIImage, withName name: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(name).jpg")
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    // Helper function to convert image to Base64
    private func convertImageToBase64String(_ image: UIImage) -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return "test"
        }
        
        return imageData.base64EncodedString()
    }
}

//final class MenuViewModel: ObservableObject {
//    @Published var items: [MenuItemViewModel]
//    
//    init(items: [MenuItemViewModel]) {
//        self.items = items
//    }
//    
//    func loadData() {
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else { return }
//        
//        items = user.dailyPrescriptionRation.compactMap { makeCell(for: $0)
//            
//        }
//    }
//        
//    func makeCell(
//        for model: DailyPrescriptionRationDomainModel
//    ) -> MenuItemViewModel? {
//        return .init(
//            id: model.id.uuidString,
//            image: "test",
//            title: model.title,
//            calories: "\(model.calories)",
//            ingredients: model.ingredients.map { $0.value },
//            description: model.preparation
//        )
//    }
//}

//final class MenuViewModel: ObservableObject {
//    @Published var breakfastItems: [MenuItemViewModel] = []
//    @Published var lunchItems: [MenuItemViewModel] = []
//    @Published var dinnerItems: [MenuItemViewModel] = []
//    @Published var isLoading: Bool = false
//
//    private let dataProcessingViewModel = DataProcessingViewModel()
//
//    init() {
//        // Подписываемся на изменения в dataProcessingViewModel.isLoading
//        dataProcessingViewModel.$isLoading.sink { [weak self] isLoading in
//            guard let self = self else { return }
//            self.isLoading = isLoading
//
//            // Если загрузка завершена и получен план питания, обновляем данные
//            if !isLoading && !self.dataProcessingViewModel.dietPlan.isEmpty {
//                self.loadData()
//            }
//        }.store(in: &cancellables)
//    }
//
//    private var cancellables = Set<AnyCancellable>()
//
//    func loadData() {
//        let storage: ModelStorage = .init()
//
//        guard let user = storage.read().first else {
//            // Если пользователь не найден, генерируем план автоматически
//            generateDietPlanIfNeeded()
//            return
//        }
//
//        // Очищаем существующие данные
//        breakfastItems = []
//        lunchItems = []
//        dinnerItems = []
//
//        // Получаем сегодняшнюю дату (начало дня)
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
//
//        // Фильтруем элементы, относящиеся к сегодняшнему дню
//        let todayItems = user.dailyPrescriptionRation.filter { item in
//            // Получаем начало дня для даты элемента
//            let itemDate = calendar.startOfDay(for: item.date)
//            // Проверяем, совпадает ли с сегодняшним днем
//            return itemDate == today
//        }
//
//        if todayItems.isEmpty {
//            // Если на сегодня нет записей, генерируем план питания
//            generateDietPlanIfNeeded()
//            return
//        }
//
//        // Группируем элементы по типу приема пищи
//        for item in todayItems {
//            if let menuItem = makeCell(for: item) {
//                switch item.mealType {
//                case "Завтрак":
//                    breakfastItems.append(menuItem)
//                case "Обед":
//                    lunchItems.append(menuItem)
//                case "Ужин":
//                    dinnerItems.append(menuItem)
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//    private func generateDietPlanIfNeeded() {
//        // Получаем данные для запроса из UserDefaults, аналогично DataProcessingScreen
//        let deadlineTimestamp = UserDefaults.standard.value(forKey: "deadline") as? TimeInterval
//        let deadlineString: String = {
//            if let timestamp = deadlineTimestamp {
//                let date = Date(timeIntervalSince1970: timestamp)
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                return formatter.string(from: date)
//            } else {
//                return "Отсутствует"
//            }
//        }()
//
//        let requestData = DietRequest(
//            deadline: deadlineString,
//            height: UserDefaults.standard.string(forKey: "heightDataCollectionScreen") ?? "Нет данных",
//            allergies: UserDefaults.standard.string(forKey: "allergiesDataCollection") ?? "Нет данных",
//            listAllegries: UserDefaults.standard.string(forKey: "allirgiesListScreen") ?? "Нет данных",
//            age: UserDefaults.standard.string(forKey: "ageDataCollection") ?? "Не указано",
//            foodPreferences: UserDefaults.standard.string(forKey: "foodPreferencesDataCollection") ?? "Не указано",
//            weightTarget: UserDefaults.standard.string(forKey: "weightTargetDataCollection") ?? "Не указано",
//            physicalLevel: UserDefaults.standard.string(forKey: "physicalLevelDataCollection") ?? "Не указано",
//            weight: UserDefaults.standard.string(forKey: "weightDataCollection") ?? "Не указано"
//        )
//
//        // Запускаем генерацию плана питания
//        dataProcessingViewModel.generateDietPlan(requestData: requestData)
//    }
//
//    func makeCell(
//        for model: DailyPrescriptionRationDomainModel
//    ) -> MenuItemViewModel? {
//        return .init(
//            id: model.id.uuidString,
//            image: "test",
//            title: model.title,
//            calories: "\(model.calories)",
//            ingredients: model.ingredients.map { $0.value },
//            description: model.preparation
//        )
//    }
//}
