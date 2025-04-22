//
//  DailyPrescriptionRationDomainModel.swift
//  AINutritionist
//
//  Created by muser on 26.03.2025.
//

import Foundation
import RealmSwift

final class DailyPrescriptionRationDomainModel: Object {
    @Persisted(primaryKey: true)  var id: UUID = .init()
    @Persisted var mealType: String = ""
    @Persisted var title: String = ""
    @Persisted var calories: Double = 0
    @Persisted var ingredients = RealmSwift.List<StringObject>()
    @Persisted var preparation: String = ""
    @Persisted var date: Date = Date()
    @Persisted var imageData: Data?
    
    convenience init(
        id: UUID = .init(),
        mealType: String,
        title: String,
        calories: Double,
        ingredients: RealmSwift.List<StringObject>,
        preparation: String,
        date: Date,
        imageData: Data? = nil
    ) {
        self.init()
        self.id = id
        self.mealType = mealType
        self.title = title
        self.calories = calories
        self.ingredients = ingredients
        self.preparation = preparation
        self.date = date
        self.imageData = imageData
    }
}

final class StringObject: Object {
    @Persisted var value: String = ""
    
    convenience init(_ value: String) {
        self.init()
        self.value = value
    }
}
