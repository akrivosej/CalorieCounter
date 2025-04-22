//
//  DataProcessingViewModel.swift
//  AINutritionist
//
//  Created by muser on 01.04.2025.
//

import SwiftUI
import Alamofire
import RealmSwift

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class DataProcessingViewModel: ObservableObject {
    @Published var dietPlan: String = ""
    @Published var isLoading: Bool = false
    
    func getAPIKey() -> String {
        let parts = [
            "sk-proj-",
            "Yzx-B8QvkfTBG-jyrmTA6f3T",
            "cNyKoxQF-GMe2Jo8lfaoMt8i",
            "0n7z10tglUq4RZ1vpvKy3obC",
            "ePT3BlbkFJT35-0SbwjqnfpbzvNWZ-CgSfi",
            "KJK",
            "A46VuUH56nZXRzKiFXuFLGLjH8ZqqtmhkW3N",
            "KdLqRPtcwA"
        ]
        return parts.joined()
    }
    
    private let openAIURL = "https://api.openai.com/v1/chat/completions"
    
    // Updated function for diet plan generation
    func generateDietPlan(requestData: DietRequest) {
        isLoading = true
        
        let calorieIntake = calculateCaloricIntake(for: requestData)
        let waterIntake = calculateWaterIntake(for: requestData)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(getAPIKey())",
            "Content-Type": "application/json"
        ]
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a diet expert. Create a meal plan in the strict format described below."],
            ["role": "user", "content": """
            Create a meal plan from \(getCurrentDate()) to \(requestData.deadline) for a person with the following parameters: \(requestData). 
            Recommended daily calorie intake: \(calorieIntake) calories. 
            Recommended water intake: \(waterIntake) liters per day.
            
            For each day, create 3 recipes: breakfast, lunch, and dinner.
            The format for each recipe must strictly be as follows:
            
            BREAKFAST:
            1. [DISH NAME] ([CALORIES] cal)
            Ingredients:
            - [INGREDIENT 1]
            - [INGREDIENT 2]
            ...
            Preparation:
            [COOKING INSTRUCTIONS]
            """]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7
        ]
        
//        AF.request(openAIURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .responseDecodable(of: OpenAIResponse.self) { response in
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    switch response.result {
//                    case .success(let aiResponse):
//                        let content = aiResponse.choices.first?.message.content ?? "Error generating plan."
//                        self.dietPlan = content
//                        self.saveDietPlanWithImages(content, waterIntake: waterIntake, calorieIntake: calorieIntake)
//                    case .failure(let error):
//                        self.dietPlan = "Ошибка в генерации Error: \(error.localizedDescription)"
//                    }
//                }
//            }
        
        AF.request(openAIURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: OpenAIResponse.self) { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch response.result {
                    case .success(let aiResponse):
                        let content = aiResponse.choices.first?.message.content ?? "Error generating plan."
                        self.dietPlan = content
                        self.saveDietPlanWithImages(content, waterIntake: waterIntake, calorieIntake: calorieIntake)
                    case .failure(let error):
                        // Улучшаем обработку ошибок
                        print("Decoding error details: \(error)")
                        
                        // Получаем исходные данные для проверки структуры ответа
                        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw response: \(jsonString)")
                        }
                        
                        self.dietPlan = "Ошибка в генерации Error: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    // Обновленная функция для сохранения плана диеты
    private func saveDietPlan(_ plan: String, waterIntake: Double, calorieIntake: Int) {
        print("Method saveDietPlan called")
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else {
            print("Error: User not found in database")
            return
        }
        
        // Проверяем, есть ли уже данные на сегодняшний день
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Проверка существующих рационов на сегодня
        let hasTodaysData = user.dailyPrescriptionRation.contains { ration in
            let rationDate = calendar.startOfDay(for: ration.date)
            return rationDate == today
        }
        
        // Если данные на сегодня уже существуют, выходим из функции
        if hasTodaysData {
            print("Data for today already exists. Skipping saving.")
            return
        }
        
        let meals = parseMeals(from: plan)
        print("Parsed meals: \(meals.count)")
        
        storage.storage.update {
            // Add new meals
            for meal in meals {
                let ration = DailyPrescriptionRationDomainModel(
                    id: .init(),
                    mealType: meal.type,
                    title: meal.title,
                    calories: meal.calories,
                    ingredients: meal.ingredients,
                    preparation: meal.preparation,
                    date: .now
                )
                user.dailyPrescriptionRation.append(ration)
            }
        }
    }

//    // Updated function for saving diet plan
//    private func saveDietPlan(_ plan: String, waterIntake: Double, calorieIntake: Int) {
//        print("Method saveDietPlan called")
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else {
//            print("Error: User not found in database")
//            return
//        }
//        
//        let meals = parseMeals(from: plan)
//        print("Parsed meals: \(meals.count)")
//        
//        storage.storage.update {
//            // Clear old data
//            user.dailyPrescriptionRation.removeAll()
//            
//            // Add new meals
//            for meal in meals {
//                
//                let ration = DailyPrescriptionRationDomainModel(
//                    id: .init(),
//                    mealType: meal.type,
//                    title: meal.title,
//                    calories: meal.calories,
//                    ingredients: meal.ingredients,
//                    preparation: meal.preparation,
//                    date: .now
//                )
//                user.dailyPrescriptionRation.append(ration)
//            }
//        }
//    }

    // Improved meal parsing function
    private func parseMeals(from plan: String) -> [(type: String, title: String, calories: Double, ingredients: RealmSwift.List<StringObject>, preparation: String)] {
        var meals: [(String, String, Double, RealmSwift.List<StringObject>, String)] = []
        
        // Updated to match uppercase meal types from the generated plan
        let mealTypes = ["BREAKFAST", "LUNCH", "DINNER"]
        let mealTypeMapping = [
            "BREAKFAST": "Breakfast",
            "LUNCH": "Lunch",
            "DINNER": "Dinner"
        ]
        
        // Split text into days and meals
        let lines = plan.components(separatedBy: .newlines)
        var currentMealType = ""
        var currentTitle = ""
        var currentCalories: Double = 0
        var currentIngredients = RealmSwift.List<StringObject>()
        var currentPreparation = ""
        var inIngredients = false
        var inPreparation = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("Processing line: \(trimmedLine)")
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Check if line is a meal type
            if mealTypes.contains(where: { trimmedLine.hasPrefix($0) }) {
                let rawMealType = mealTypes.first(where: { trimmedLine.hasPrefix($0) }) ?? ""
                currentMealType = mealTypeMapping[rawMealType] ?? rawMealType
                print("Found meal type: \(currentMealType)")
                inIngredients = false
                inPreparation = false
                continue
            }
            
            // Check if line is a dish name with calories
            // Updated regex to be more flexible with spacing
            if let recipeMatch = trimmedLine.range(of: #"^\d+\.\s+(.+?)\s+\((\d+)\s*cal\)"#, options: .regularExpression) {
                // If we already have a dish collected, add it to the list
                if !currentTitle.isEmpty {
                    meals.append((currentMealType, currentTitle, currentCalories, currentIngredients, currentPreparation))
                }
                
                // Start collecting a new dish
                let fullMatch = String(trimmedLine[recipeMatch])
                
                // Extract title
                if let titleMatch = fullMatch.range(of: #"^\d+\.\s+(.+?)\s+\("#, options: .regularExpression) {
                    currentTitle = String(fullMatch[titleMatch]).replacingOccurrences(of: #"^\d+\.\s+"#, with: "", options: .regularExpression)
                    currentTitle = currentTitle.replacingOccurrences(of: #"\s+\($"#, with: "", options: .regularExpression)
                }
                
                // Extract calories
                if let caloriesMatch = fullMatch.range(of: #"\((\d+)\s*cal\)"#, options: .regularExpression),
                   let caloriesValueMatch = String(fullMatch[caloriesMatch]).range(of: #"(\d+)"#, options: .regularExpression) {
                    let caloriesStr = String(String(fullMatch[caloriesMatch])[caloriesValueMatch])
                    currentCalories = Double(caloriesStr) ?? 0.0
                }
                
                // Reset ingredients and preparation for new dish
                currentIngredients = RealmSwift.List<StringObject>()
                currentPreparation = ""
                inIngredients = false
                inPreparation = false
                continue
            }
            
            // Check if we're entering the ingredients section
            if trimmedLine == "Ingredients:" {
                inIngredients = true
                inPreparation = false
                continue
            }
            
            // Check if we're entering the preparation section
            if trimmedLine == "Preparation:" {
                inIngredients = false
                inPreparation = true
                continue
            }
            
            // Collect ingredients
            if inIngredients {
                let ingredient = trimmedLine.replacingOccurrences(of: #"^[\s-]+"#, with: "", options: .regularExpression)
                if !ingredient.isEmpty {
                    let ingredientObject = StringObject(ingredient)
                    currentIngredients.append(ingredientObject)
                }
            }
            
            // Collect cooking instructions
            if inPreparation {
                if currentPreparation.isEmpty {
                    currentPreparation = trimmedLine
                } else {
                    currentPreparation += "\n" + trimmedLine
                }
            }
        }
        
        // Add the last dish if it exists
        if !currentTitle.isEmpty {
            meals.append((currentMealType, currentTitle, currentCalories, currentIngredients, currentPreparation))
        }
        
        return meals
    }

    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func calculateCaloricIntake(for requestData: DietRequest) -> Int {
        guard let weight = Double(requestData.weight),
              let height = Double(requestData.height),
              let age = Int(requestData.age),
              let activityLevel = Double(requestData.physicalLevel) else { return 0 }
        
        let bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        return Int(bmr * activityLevel)
    }
    
    private func calculateWaterIntake(for requestData: DietRequest) -> Double {
        guard let weight = Double(requestData.weight) else { return 0.0 }
        return weight * 0.03
    }
}

struct OpenAIImageResponse: Codable {
    struct ImageData: Codable {
        let url: String
    }
    let data: [ImageData]
}

extension DataProcessingViewModel {
    // Function to generate food image
    func generateFoodImage(for dishName: String, completion: @escaping (UIImage?) -> Void) {
        isLoading = true
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(getAPIKey())",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "prompt": "Photorealistic image of \(dishName), food photography, high quality, on a white plate, top view",
            "n": 1,
            "size": "512x512"
        ]
        
        let imageURL = "https://api.openai.com/v1/images/generations"
        
        AF.request(imageURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: OpenAIImageResponse.self) { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    switch response.result {
                    case .success(let imageResponse):
                        if let imageUrl = imageResponse.data.first?.url, let url = URL(string: imageUrl) {
                            // Download image by URL
                            self.downloadImage(from: url) { image in
                                completion(image)
                            }
                        } else {
                            completion(nil)
                        }
                    case .failure(let error):
                        print("Error generating image: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }
    }
    
    // Helper function to download image by URL
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    // Обновленная функция для сохранения плана диеты с изображениями
    func saveDietPlanWithImages(_ plan: String, waterIntake: Double, calorieIntake: Int) {
        print("Method saveDietPlanWithImages called")
        let storage: ModelStorage = .init()
        
        guard let user = storage.read().first else {
            print("Error: User not found in database")
            return
        }
        
        // Проверяем, есть ли уже данные на сегодняшний день
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Проверка существующих рационов на сегодня
        let hasTodaysData = user.dailyPrescriptionRation.contains { ration in
            let rationDate = calendar.startOfDay(for: ration.date)
            return rationDate == today
        }
        
        // Если данные на сегодня уже существуют, выходим из функции
        if hasTodaysData {
            print("Data for today already exists. Skipping saving.")
            return
        }
        
        // Продолжаем сохранение, если данных на сегодня нет
        let meals = parseMeals(from: plan)
        print("Parsed meals: \(meals.count)")
        
        // Create a group for asynchronous operations
        let group = DispatchGroup()
        
        // Temporary storage for meals with images
        var mealsWithImages: [(meal: (type: String, title: String, calories: Double, ingredients: RealmSwift.List<StringObject>, preparation: String), imageData: Data?)] = []
        
        // For each meal generate an image
        for meal in meals {
            group.enter()
            
            generateFoodImage(for: meal.title) { image in
                let imageData = image?.jpegData(compressionQuality: 0.8)
                mealsWithImages.append((meal: meal, imageData: imageData))
                group.leave()
            }
        }
        
        // After completing all image generation operations
        group.notify(queue: .main) {
            storage.storage.update {
                // Add new meals with images
                for mealWithImage in mealsWithImages {
                    let ration = DailyPrescriptionRationDomainModel(
                        id: .init(),
                        mealType: mealWithImage.meal.type,
                        title: mealWithImage.meal.title,
                        calories: mealWithImage.meal.calories,
                        ingredients: mealWithImage.meal.ingredients,
                        preparation: mealWithImage.meal.preparation,
                        date: .now,
                        imageData: mealWithImage.imageData
                    )
                    user.dailyPrescriptionRation.append(ration)
                }
            }
        }
    }
    
//    // Updated function to save diet plan with images
//    func saveDietPlanWithImages(_ plan: String, waterIntake: Double, calorieIntake: Int) {
//        print("Method saveDietPlanWithImages called")
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else {
//            print("Error: User not found in database")
//            return
//        }
//        
//        let meals = parseMeals(from: plan)
//        print("Parsed meals: \(meals.count)")
//        
//        // Create a group for asynchronous operations
//        let group = DispatchGroup()
//        
//        // Temporary storage for meals with images
//        var mealsWithImages: [(meal: (type: String, title: String, calories: Double, ingredients: RealmSwift.List<StringObject>, preparation: String), imageData: Data?)] = []
//        
//        // For each meal generate an image
//        for meal in meals {
//            group.enter()
//            
//            generateFoodImage(for: meal.title) { image in
//                let imageData = image?.jpegData(compressionQuality: 0.8)
//                mealsWithImages.append((meal: meal, imageData: imageData))
//                group.leave()
//            }
//        }
//        
//        // After completing all image generation operations
//        group.notify(queue: .main) {
//            storage.storage.update {
//                // First clear old data
//                user.dailyPrescriptionRation.removeAll()
//                
//                // Add new meals with images
//                for mealWithImage in mealsWithImages {
//                    let ration = DailyPrescriptionRationDomainModel(
//                        id: .init(),
//                        mealType: mealWithImage.meal.type,
//                        title: mealWithImage.meal.title,
//                        calories: mealWithImage.meal.calories,
//                        ingredients: mealWithImage.meal.ingredients,
//                        preparation: mealWithImage.meal.preparation,
//                        date: .now,
//                        imageData: mealWithImage.imageData
//                    )
//                    user.dailyPrescriptionRation.append(ration)
//                }
//            }
//        }
//    }
}








//struct OpenAIResponse: Codable {
//    struct Choice: Codable {
//        struct Message: Codable {
//            let content: String
//        }
//        let message: Message
//    }
//    let choices: [Choice]
//}
//
//class DataProcessingViewModel: ObservableObject {
//    @Published var dietPlan: String = ""
//    @Published var isLoading: Bool = false
//    
//    private let openAIURL = "https://api.openai.com/v1/chat/completions"
//    
//    // Обновленная функция для генерации диет-плана
//    func generateDietPlan(requestData: DietRequest) {
//        isLoading = true
//        
//        let calorieIntake = calculateCaloricIntake(for: requestData)
//        let waterIntake = calculateWaterIntake(for: requestData)
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(apiKey)",
//            "Content-Type": "application/json"
//        ]
//        
//        let messages: [[String: String]] = [
//            ["role": "system", "content": "Ты — эксперт по диетам. Создай план питания в строгом формате, описанном ниже."],
//            ["role": "user", "content": """
//            Создай план питания с \(getCurrentDate()) по \(requestData.deadline) для человека со следующими параметрами: \(requestData). 
//            Рекомендуемая дневная норма калорий: \(calorieIntake) ккал. 
//            Рекомендуемое количество воды: \(waterIntake) литров в день.
//            
//            Для каждого дня создай по 3 рецепта: завтрак, обед и ужин.
//            Формат для каждого рецепта должен быть строго следующим:
//            
//            [ТИП ПРИЕМА ПИЩИ]:
//            1. [НАЗВАНИЕ БЛЮДА] ([КАЛОРИИ] ккал)
//            Ингредиенты:
//            - [ИНГРЕДИЕНТ 1]
//            - [ИНГРЕДИЕНТ 2]
//            ...
//            Приготовление:
//            [ИНСТРУКЦИИ ПО ПРИГОТОВЛЕНИЮ]
//            """]
//        ]
//        
//        let parameters: [String: Any] = [
//            "model": "gpt-4",
//            "messages": messages,
//            "temperature": 0.7
//        ]
//        
//        AF.request(openAIURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .responseDecodable(of: OpenAIResponse.self) { response in
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    switch response.result {
//                    case .success(let aiResponse):
//                        let content = aiResponse.choices.first?.message.content ?? "Ошибка генерации плана."
//                        self.dietPlan = content
//                        self.saveDietPlanWithImages(content, waterIntake: waterIntake, calorieIntake: calorieIntake)
//                    case .failure(let error):
//                        self.dietPlan = "Ошибка: \(error.localizedDescription)"
//                    }
//                }
//            }
//    }
//
//    // Обновленная функция сохранения диет-плана
//    private func saveDietPlan(_ plan: String, waterIntake: Double, calorieIntake: Int) {
//        print("Метод saveDietPlan вызван")
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else {
//            print("Ошибка: Пользователь не найден в базе")
//            return
//        }
//        
//        let meals = parseMeals(from: plan)
//        print("Распарсенные блюда: \(meals.count)")
//        
//        storage.storage.update {
////             Добавляем данные о водном балансе и калориях на текущий день
////            user.waterBalance = waterIntake
////            user.kklBalance = Double(calorieIntake)
////            
////            // Обновляем дату создания
////            user.creationDate = Date()
////            
////             Сначала очищаем старые данные (опционально, если требуется)
////            storage.store(item: .init(creationDate: Date(), waterBalance: waterIntake, kklBalance: Double(calorieIntake), dailyRation: .init(), dailyPrescriptionRation: .init()))
//             user.dailyPrescriptionRation.removeAll()
//            
//            // Добавляем новые рационы
//            for meal in meals {
//                
//                let ration = DailyPrescriptionRationDomainModel(
//                    id: .init(),
//                    mealType: meal.type,
//                    title: meal.title,
//                    calories: meal.calories,
//                    ingredients: meal.ingredients,
//                    preparation: meal.preparation,
//                    date: .now
//                )
//                user.dailyPrescriptionRation.append(ration)
//            }
//        }
//    }
//
//    // Улучшенная функция парсинга блюд
//    private func parseMeals(from plan: String) -> [(type: String, title: String, calories: Double, ingredients: RealmSwift.List<StringObject>, preparation: String)] {
//        var meals: [(String, String, Double, RealmSwift.List<StringObject>, String)] = []
//        let mealTypes = ["Завтрак", "Обед", "Ужин"]
//        
//        // Разбиваем весь текст на дни и блюда
//        let lines = plan.components(separatedBy: .newlines)
//        var currentMealType = ""
//        var currentTitle = ""
//        var currentCalories: Double = 0
//        var currentIngredients = RealmSwift.List<StringObject>()
//        var currentPreparation = ""
//        var inIngredients = false
//        var inPreparation = false
//        
//        for line in lines {
//            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            // Пропускаем пустые строки
//            if trimmedLine.isEmpty {
//                continue
//            }
//            
//            // Проверяем, является ли строка названием типа приема пищи
//            if mealTypes.contains(where: { trimmedLine.hasPrefix($0) }) {
//                currentMealType = mealTypes.first(where: { trimmedLine.hasPrefix($0) }) ?? ""
//                inIngredients = false
//                inPreparation = false
//                continue
//            }
//            
//            // Проверяем, является ли строка названием блюда с калориями
//            if let recipeMatch = trimmedLine.range(of: #"^\d+\.\s+(.+)\s+\((\d+)\s*ккал\)"#, options: .regularExpression) {
//                // Если уже есть собранное блюдо, добавим его в список
//                if !currentTitle.isEmpty {
//                    meals.append((currentMealType, currentTitle, currentCalories, currentIngredients, currentPreparation))
//                }
//                
//                // Начинаем собирать новое блюдо
//                let fullMatch = String(trimmedLine[recipeMatch])
//                
//                // Извлекаем название
//                if let titleMatch = fullMatch.range(of: #"^\d+\.\s+(.+)\s+\("#, options: .regularExpression) {
//                    currentTitle = String(fullMatch[titleMatch]).replacingOccurrences(of: #"^\d+\.\s+"#, with: "", options: .regularExpression)
//                    currentTitle = currentTitle.replacingOccurrences(of: #"\s+\($"#, with: "", options: .regularExpression)
//                }
//                
//                // Извлекаем калории
//                if let caloriesMatch = fullMatch.range(of: #"\((\d+)\s*ккал\)"#, options: .regularExpression),
//                   let caloriesValueMatch = String(fullMatch[caloriesMatch]).range(of: #"(\d+)"#, options: .regularExpression) {
//                    let caloriesStr = String(String(fullMatch[caloriesMatch])[caloriesValueMatch])
//                    currentCalories = Double(caloriesStr) ?? 0.0
//                }
//                
//                // Сбрасываем ингредиенты и приготовление для нового блюда
//                currentIngredients = RealmSwift.List<StringObject>()
//                currentPreparation = ""
//                inIngredients = false
//                inPreparation = false
//                continue
//            }
//            
//            // Проверяем, входим ли мы в секцию ингредиентов
//            if trimmedLine == "Ингредиенты:" {
//                inIngredients = true
//                inPreparation = false
//                continue
//            }
//            
//            // Проверяем, входим ли мы в секцию приготовления
//            if trimmedLine == "Приготовление:" {
//                inIngredients = false
//                inPreparation = true
//                continue
//            }
//            
//            // Собираем ингредиенты
//            if inIngredients {
//                let ingredient = trimmedLine.replacingOccurrences(of: #"^[\s-]+"#, with: "", options: .regularExpression)
//                if !ingredient.isEmpty {
//                    let ingredientObject = StringObject(ingredient)
//                    currentIngredients.append(ingredientObject)
//                }
//            }
//            
//            // Собираем инструкции по приготовлению
//            if inPreparation {
//                if currentPreparation.isEmpty {
//                    currentPreparation = trimmedLine
//                } else {
//                    currentPreparation += "\n" + trimmedLine
//                }
//            }
//        }
//        
//        // Добавляем последнее блюдо, если оно есть
//        if !currentTitle.isEmpty {
//            meals.append((currentMealType, currentTitle, currentCalories, currentIngredients, currentPreparation))
//        }
//        
//        return meals
//    }
//
//    private func getCurrentDate() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.string(from: Date())
//    }
//    
//    private func calculateCaloricIntake(for requestData: DietRequest) -> Int {
//        guard let weight = Double(requestData.weight),
//              let height = Double(requestData.height),
//              let age = Int(requestData.age),
//              let activityLevel = Double(requestData.physicalLevel) else { return 0 }
//        
//        let bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
//        return Int(bmr * activityLevel)
//    }
//    
//    private func calculateWaterIntake(for requestData: DietRequest) -> Double {
//        guard let weight = Double(requestData.weight) else { return 0.0 }
//        return weight * 0.03
//    }
//}
//
//struct OpenAIImageResponse: Codable {
//    struct ImageData: Codable {
//        let url: String
//    }
//    let data: [ImageData]
//}
//
//extension DataProcessingViewModel {
//    // Функция для генерации изображения блюда
//    func generateFoodImage(for dishName: String, completion: @escaping (UIImage?) -> Void) {
//        isLoading = true
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(apiKey)",
//            "Content-Type": "application/json"
//        ]
//        
//        let parameters: [String: Any] = [
//            "prompt": "Фотореалистичное изображение блюда \(dishName), фуд-фотография, высокое качество, на белой тарелке, вид сверху",
//            "n": 1,
//            "size": "512x512"
//        ]
//        
//        let imageURL = "https://api.openai.com/v1/images/generations"
//        
//        AF.request(imageURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .responseDecodable(of: OpenAIImageResponse.self) { response in
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    
//                    switch response.result {
//                    case .success(let imageResponse):
//                        if let imageUrl = imageResponse.data.first?.url, let url = URL(string: imageUrl) {
//                            // Загрузка изображения по URL
//                            self.downloadImage(from: url) { image in
//                                completion(image)
//                            }
//                        } else {
//                            completion(nil)
//                        }
//                    case .failure(let error):
//                        print("Ошибка при генерации изображения: \(error.localizedDescription)")
//                        completion(nil)
//                    }
//                }
//            }
//    }
//    
//    // Вспомогательная функция для загрузки изображения по URL
//    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
//        AF.request(url).responseData { response in
//            if let data = response.data, let image = UIImage(data: data) {
//                completion(image)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//    
//    // Обновленная функция сохранения диет-плана с изображениями
//    func saveDietPlanWithImages(_ plan: String, waterIntake: Double, calorieIntake: Int) {
//        print("Метод saveDietPlanWithImages вызван")
//        let storage: ModelStorage = .init()
//        
//        guard let user = storage.read().first else {
//            print("Ошибка: Пользователь не найден в базе")
//            return
//        }
//        
//        let meals = parseMeals(from: plan)
//        print("Распарсенные блюда: \(meals.count)")
//        
//        // Создаем группу для асинхронных операций
//        let group = DispatchGroup()
//        
//        // Временное хранилище для блюд с изображениями
//        var mealsWithImages: [(meal: (type: String, title: String, calories: Double, ingredients: RealmSwift.List<StringObject>, preparation: String), imageData: Data?)] = []
//        
//        // Для каждого блюда генерируем изображение
//        for meal in meals {
//            group.enter()
//            
//            generateFoodImage(for: meal.title) { image in
//                let imageData = image?.jpegData(compressionQuality: 0.8)
//                mealsWithImages.append((meal: meal, imageData: imageData))
//                group.leave()
//            }
//        }
//        
//        // После завершения всех операций генерации изображений
//        group.notify(queue: .main) {
//            storage.storage.update {
//                // Сначала очищаем старые данные (опционально)
//                user.dailyPrescriptionRation.removeAll()
//                
//                // Добавляем новые рационы с изображениями
//                for mealWithImage in mealsWithImages {
//                    let ration = DailyPrescriptionRationDomainModel(
//                        id: .init(),
//                        mealType: mealWithImage.meal.type,
//                        title: mealWithImage.meal.title,
//                        calories: mealWithImage.meal.calories,
//                        ingredients: mealWithImage.meal.ingredients,
//                        preparation: mealWithImage.meal.preparation,
//                        date: .now,
//                        imageData: mealWithImage.imageData
//                    )
//                    user.dailyPrescriptionRation.append(ration)
//                }
//            }
//        }
//    }
//}
