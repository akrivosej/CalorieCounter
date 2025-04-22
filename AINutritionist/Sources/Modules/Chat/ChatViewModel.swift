//
//  ChatViewModel.swift
//  AINutritionist
//
//  Created by muser on 03.04.2025.
//

import Foundation


class ChatViewModel: ObservableObject {
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
    
    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
        isLoading = true
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(getAPIKey())",
            "Content-Type": "application/json"
        ]
        
        let systemMessage = "You are an AI nutritionist specializing in healthy eating, diet planning, and nutrition advice. Answer questions only related to nutrition, diets, healthy recipe ideas, calorie counting, and nutrient tracking. If a question is not related to nutrition, politely remind that you can only help with topics related to food and nutrition. Provide concise but helpful answers in English."
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemMessage],
            ["role": "user", "content": message]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: openAIURL) else {
            DispatchQueue.main.async {
                self.isLoading = false
                completion("An error occurred while sending the request.")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Convert parameters to JSON and set as request body
        if let httpBody = try? JSONSerialization.data(withJSONObject: parameters) {
            request.httpBody = httpBody
        }
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion("An error occurred while getting a response.")
                    return
                }
                
                guard let data = data else {
                    completion("Failed to get data.")
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = jsonResult["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        completion(content)
                    } else {
                        completion("Could not process the response.")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion("An error occurred while processing the response.")
                }
            }
        }.resume()
    }
}

//class ChatViewModel: ObservableObject {
//    @Published var isLoading: Bool = false
//    private let openAIURL = "https://api.openai.com/v1/chat/completions"
//    
//    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
//        isLoading = true
//        
//        let headers: [String: String] = [
//            "Authorization": "Bearer \(apiKey)",
//            "Content-Type": "application/json"
//        ]
//        
//        let systemMessage = "Ты — AI-диетолог, специализирующийся на здоровом питании, рационе и диетах. Отвечай на вопросы только по теме питания, диет, рецептов полезных блюд, расчета калорий и нутриентов. Если вопрос не связан с питанием, вежливо напомни, что ты можешь помочь только с темами, связанными с питанием. Давай краткие, но полезные ответы."
//        
//        let messages: [[String: String]] = [
//            ["role": "system", "content": systemMessage],
//            ["role": "user", "content": message]
//        ]
//        
//        let parameters: [String: Any] = [
//            "model": "gpt-3.5-turbo",
//            "messages": messages,
//            "temperature": 0.7,
//            "max_tokens": 500
//        ]
//        
//        guard let url = URL(string: openAIURL) else {
//            DispatchQueue.main.async {
//                self.isLoading = false
//                completion("Произошла ошибка при отправке запроса.")
//            }
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Добавляем заголовки
//        for (key, value) in headers {
//            request.addValue(value, forHTTPHeaderField: key)
//        }
//        
//        // Преобразуем параметры в JSON и устанавливаем как тело запроса
//        if let httpBody = try? JSONSerialization.data(withJSONObject: parameters) {
//            request.httpBody = httpBody
//        }
//        
//        // Отправляем запрос
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                if let error = error {
//                    print("Ошибка: \(error.localizedDescription)")
//                    completion("Произошла ошибка при получении ответа.")
//                    return
//                }
//                
//                guard let data = data else {
//                    completion("Не удалось получить данные.")
//                    return
//                }
//                
//                do {
//                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let choices = jsonResult["choices"] as? [[String: Any]],
//                       let firstChoice = choices.first,
//                       let message = firstChoice["message"] as? [String: Any],
//                       let content = message["content"] as? String {
//                        
//                        completion(content)
//                    } else {
//                        completion("Не удалось распознать ответ.")
//                    }
//                } catch {
//                    print("Ошибка при парсинге JSON: \(error.localizedDescription)")
//                    completion("Произошла ошибка при обработке ответа.")
//                }
//            }
//        }.resume()
//    }
//}
