//
//  MenuDetailsViewModel.swift
//  AINutritionist
//
//  Created by muser on 27.03.2025.
//

import Foundation
import UIKit

final class MenuDetailsViewModel: ObservableObject, Hashable {
    @Published var id: String
    @Published var image: String
    @Published var title: String
    @Published var calories: String
    @Published var ingredients: [String]
    @Published var description: String
    
    init(id: String, image: String, title: String, calories: String, ingredients: [String], description: String) {
        self.id = id
        self.image = image
        self.title = title
        self.calories = calories
        self.ingredients = ingredients
        self.description = description
    }
    
    func getImage() -> UIImage? {
        // Вариант 1: Если image - это имя файла
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(image).jpg")
            if let imageData = try? Data(contentsOf: fileURL) {
                return UIImage(data: imageData)
            }
        }
        
        // Вариант 2: Если image - это Base64-строка
        if let imageData = Data(base64Encoded: image) {
            return UIImage(data: imageData)
        }
        
        // Если не удалось получить изображение, возвращаем изображение по умолчанию
        return UIImage(named: "test")
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MenuDetailsViewModel, rhs: MenuDetailsViewModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.image == rhs.image &&
            lhs.title == rhs.title &&
            lhs.calories == rhs.calories &&
            lhs.ingredients == rhs.ingredients &&
            lhs.description == rhs.description
    }
}
