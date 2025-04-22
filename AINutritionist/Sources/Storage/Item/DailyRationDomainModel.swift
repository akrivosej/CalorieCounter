//
//  DailyRationDomainModel.swift
//  AINutritionist
//
//  Created by muser on 26.03.2025.
//

import Foundation
import RealmSwift

final class DailyRationDomainModel: Object {
    @Persisted(primaryKey: true)  var id: UUID = .init()
    @Persisted var creationDate: Date = .init()
    @Persisted var title: String = ""
    @Persisted var calories: String = ""
    @Persisted var weight: String = ""
    
    convenience init(
        id: UUID = .init(),
        creationDate: Date,
        title: String,
        calories: String,
        weight: String
    ) {
        self.init()
        self.id = id
        self.creationDate = creationDate
        self.title = title
        self.calories = calories
        self.weight = weight
    }
}
