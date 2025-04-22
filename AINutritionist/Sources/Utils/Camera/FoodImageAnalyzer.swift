//
//  FoodImageAnalyzer.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import Foundation
import UIKit
import Alamofire

class FoodImageAnalyzer {
    
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
    
    func analyzeFoodImage(image: UIImage, completion: @escaping (String, String, String) -> Void) {
        print("📸 [FoodAnalyzer] Начало анализа изображения...")
        print("📸 [FoodAnalyzer] Размер изображения: \(image.size.width)x\(image.size.height)")
        
        // Конвертируем изображение в base64
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("❌ [FoodAnalyzer] Ошибка конвертации изображения в JPEG")
            completion("Unknown Food", "0", "0")
            return
        }
        
        print("✅ [FoodAnalyzer] Изображение конвертировано в JPEG, размер: \(imageData.count) байт")
        let base64Image = imageData.base64EncodedString()
        print("✅ [FoodAnalyzer] Изображение закодировано в base64")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(getAPIKey())",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "This is a photo of food. Identify what food it is, and provide an estimate of its calories and weight in grams. Format your answer as JSON with fields 'food_name', 'calories', and 'weight_g'. Give just the JSON without any extra text."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        print("🌐 [FoodAnalyzer] Отправка запроса к OpenAI API...")
        print("🌐 [FoodAnalyzer] Используемая модель: gpt-4o")
        
        AF.request("https://api.openai.com/v1/chat/completions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                print("📥 [FoodAnalyzer] Получен ответ от API")
                
                // Логирование HTTP статуса
                if let statusCode = response.response?.statusCode {
                    print("🔢 [FoodAnalyzer] HTTP статус: \(statusCode)")
                    if statusCode != 200 {
                        print("⚠️ [FoodAnalyzer] Неуспешный HTTP статус: \(statusCode)")
                    }
                }
                
                switch response.result {
                case .success(let data):
                    print("✅ [FoodAnalyzer] Данные успешно получены, размер: \(data.count) байт")
                    
                    // Логирование сырого ответа для отладки
                    if let rawResponseString = String(data: data, encoding: .utf8) {
                        print("📋 [FoodAnalyzer] Сырой ответ API: \(rawResponseString)")
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("✅ [FoodAnalyzer] JSON успешно распарсен")
                            
                            // Проверка на наличие ошибки в ответе API
                            if let error = json["error"] as? [String: Any] {
                                print("❌ [FoodAnalyzer] API вернул ошибку: \(error)")
                                DispatchQueue.main.async {
                                    completion("Unknown Food (API Error)", "0", "0")
                                }
                                return
                            }
                            
                            if let choices = json["choices"] as? [[String: Any]] {
                                print("✅ [FoodAnalyzer] Найдены choices в ответе, количество: \(choices.count)")
                                
                                if let firstChoice = choices.first {
                                    print("✅ [FoodAnalyzer] Получен первый choice")
                                    
                                    if let message = firstChoice["message"] as? [String: Any] {
                                        print("✅ [FoodAnalyzer] Найдено message в choice")
                                        
                                        if let content = message["content"] as? String {
                                            print("✅ [FoodAnalyzer] Получен content: \(content)")
                                            
                                            // Попытка напрямую распарсить JSON из content
                                            if let jsonData = content.data(using: .utf8) {
                                                do {
                                                    if let foodInfo = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                                        print("✅ [FoodAnalyzer] JSON успешно извлечен из content")
                                                        
                                                        let foodName = foodInfo["food_name"] as? String ?? "Unknown Food"
                                                        let calories = String(describing: foodInfo["calories"] ?? "0")
                                                        let weight = String(describing: foodInfo["weight_g"] ?? "0")
                                                        
                                                        print("🍽 [FoodAnalyzer] Распознано: блюдо='\(foodName)', калории='\(calories)', вес='\(weight)'")
                                                        
                                                        DispatchQueue.main.async {
                                                            completion(foodName, calories, weight)
                                                        }
                                                    } else {
                                                        print("⚠️ [FoodAnalyzer] Не удалось преобразовать content в словарь")
                                                        self.tryExtractJsonFromText(content, completion: completion)
                                                    }
                                                } catch {
                                                    print("⚠️ [FoodAnalyzer] Ошибка парсинга JSON из content: \(error)")
                                                    self.tryExtractJsonFromText(content, completion: completion)
                                                }
                                            } else {
                                                print("⚠️ [FoodAnalyzer] Не удалось преобразовать content в Data")
                                                self.tryExtractJsonFromText(content, completion: completion)
                                            }
                                        } else {
                                            print("❌ [FoodAnalyzer] Content не найден в message")
                                            DispatchQueue.main.async {
                                                completion("Unknown Food (No Content)", "0", "0")
                                            }
                                        }
                                    } else {
                                        print("❌ [FoodAnalyzer] Message не найден в choice")
                                        DispatchQueue.main.async {
                                            completion("Unknown Food (No Message)", "0", "0")
                                        }
                                    }
                                } else {
                                    print("❌ [FoodAnalyzer] Choices пуст")
                                    DispatchQueue.main.async {
                                        completion("Unknown Food (Empty Choices)", "0", "0")
                                    }
                                }
                            } else {
                                print("❌ [FoodAnalyzer] Choices не найден в ответе")
                                DispatchQueue.main.async {
                                    completion("Unknown Food (No Choices)", "0", "0")
                                }
                            }
                        } else {
                            print("❌ [FoodAnalyzer] Не удалось преобразовать данные в JSON")
                            DispatchQueue.main.async {
                                completion("Unknown Food (JSON Parse Error)", "0", "0")
                            }
                        }
                    } catch {
                        print("❌ [FoodAnalyzer] Ошибка при парсинге JSON: \(error)")
                        DispatchQueue.main.async {
                            completion("Unknown Food (JSON Error)", "0", "0")
                        }
                    }
                    
                case .failure(let error):
                    print("❌ [FoodAnalyzer] Ошибка соединения с OpenAI API: \(error)")
                    DispatchQueue.main.async {
                        completion("Unknown Food (Connection Error)", "0", "0")
                    }
                }
            }
    }
    
    // Вспомогательный метод для извлечения JSON из текстового ответа
    private func tryExtractJsonFromText(_ text: String, completion: @escaping (String, String, String) -> Void) {
        print("🔍 [FoodAnalyzer] Попытка извлечь JSON из текста...")
        
        // Попытаемся найти фигурные скобки для определения JSON
        if let jsonStart = text.range(of: "{"),
           let jsonEnd = text.range(of: "}", options: .backwards) {
            let jsonString = text[jsonStart.lowerBound...jsonEnd.upperBound]
            print("✅ [FoodAnalyzer] Найден возможный JSON: \(jsonString)")
            
            if let jsonData = String(jsonString).data(using: .utf8),
               let foodInfo = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                
                let foodName = foodInfo["food_name"] as? String ?? "Unknown Food"
                let calories = String(describing: foodInfo["calories"] ?? "0")
                let weight = String(describing: foodInfo["weight_g"] ?? "0")
                
                print("🍽 [FoodAnalyzer] Распознано из извлеченного JSON: блюдо='\(foodName)', калории='\(calories)', вес='\(weight)'")
                
                DispatchQueue.main.async {
                    completion(foodName, calories, weight)
                }
            } else {
                print("❌ [FoodAnalyzer] Не удалось распарсить извлеченный JSON")
                DispatchQueue.main.async {
                    completion("Unknown Food (JSON Extraction Failed)", "0", "0")
                }
            }
        } else {
            print("❌ [FoodAnalyzer] JSON структура не найдена в тексте")
            DispatchQueue.main.async {
                completion("Unknown Food (No JSON Structure)", "0", "0")
            }
        }
    }
}

//class FoodImageAnalyzer {
//    
//    func analyzeFoodImage(image: UIImage, completion: @escaping (String, String, String) -> Void) {
//        // Конвертируем изображение в base64
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//            completion("Unknown Food", "0", "0")
//            return
//        }
//        
//        let base64Image = imageData.base64EncodedString()
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(apiKey)",
//            "Content-Type": "application/json"
//        ]
//        
//        let parameters: [String: Any] = [
//            "model": "gpt-4-vision-preview",
//            "messages": [
//                [
//                    "role": "user",
//                    "content": [
//                        [
//                            "type": "text",
//                            "text": "This is a photo of food. Identify what food it is, and provide an estimate of its calories and weight in grams. Format your answer as JSON with fields 'food_name', 'calories', and 'weight_g'. Give just the JSON without any extra text."
//                        ],
//                        [
//                            "type": "image_url",
//                            "image_url": [
//                                "url": "data:image/jpeg;base64,\(base64Image)"
//                            ]
//                        ]
//                    ]
//                ]
//            ],
//            "max_tokens": 300
//        ]
//        
//        AF.request("https://api.openai.com/v1/chat/completions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .responseData { response in
//                switch response.result {
//                case .success(let data):
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                           let choices = json["choices"] as? [[String: Any]],
//                           let firstChoice = choices.first,
//                           let message = firstChoice["message"] as? [String: Any],
//                           let content = message["content"] as? String {
//                            
//                            // Извлекаем JSON из ответа
//                            if let jsonData = content.data(using: .utf8),
//                               let foodInfo = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
//                                
//                                let foodName = foodInfo["food_name"] as? String ?? "Unknown Food"
//                                let calories = String(describing: foodInfo["calories"] ?? "0")
//                                let weight = String(describing: foodInfo["weight_g"] ?? "0")
//                                
//                                DispatchQueue.main.async {
//                                    completion(foodName, calories, weight)
//                                }
//                            } else {
//                                // Если ответ не в формате JSON, попробуем извлечь JSON из текста
//                                if let jsonStart = content.range(of: "{"),
//                                   let jsonEnd = content.range(of: "}", options: .backwards) {
//                                    let jsonString = content[jsonStart.lowerBound...jsonEnd.upperBound]
//                                    
//                                    if let jsonData = String(jsonString).data(using: .utf8),
//                                       let foodInfo = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
//                                        
//                                        let foodName = foodInfo["food_name"] as? String ?? "Unknown Food"
//                                        let calories = String(describing: foodInfo["calories"] ?? "0")
//                                        let weight = String(describing: foodInfo["weight_g"] ?? "0")
//                                        
//                                        DispatchQueue.main.async {
//                                            completion(foodName, calories, weight)
//                                        }
//                                    }
//                                } else {
//                                    DispatchQueue.main.async {
//                                        completion("Unknown Food", "0", "0")
//                                    }
//                                }
//                            }
//                        } else {
//                            DispatchQueue.main.async {
//                                completion("Unknown Food", "0", "0")
//                            }
//                        }
//                    } catch {
//                        print("Error parsing JSON: \(error)")
//                        DispatchQueue.main.async {
//                            completion("Unknown Food", "0", "0")
//                        }
//                    }
//                    
//                case .failure(let error):
//                    print("Error with OpenAI API: \(error)")
//                    DispatchQueue.main.async {
//                        completion("Unknown Food", "0", "0")
//                    }
//                }
//            }
//    }
//}
