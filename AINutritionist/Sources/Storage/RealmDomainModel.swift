//
//  RealmDomainModel.swift
//  AINutritionist
//
//  Created by muser on 26.03.2025.
//

import Foundation
import RealmSwift

final class RealmDomainModel: Object {
    @Persisted(primaryKey: true)  var id: UUID = .init()
    @Persisted var creationDate: Date = .init()
    @Persisted var waterBalance: Double = 0
    @Persisted var kklBalance: Double = 0
    @Persisted var dailyRation: List<DailyRationDomainModel>
    @Persisted var dailyPrescriptionRation: List<DailyPrescriptionRationDomainModel>

    convenience init(
        id: UUID = .init(),
        creationDate: Date,
        waterBalance: Double,
        kklBalance: Double,
        dailyRation: List<DailyRationDomainModel>,
        dailyPrescriptionRation: List<DailyPrescriptionRationDomainModel>
    ) {
        self.init()
        self.id = id
        self.creationDate = creationDate
        self.waterBalance = waterBalance
        self.kklBalance = kklBalance
        self.dailyRation = dailyRation
        self.dailyPrescriptionRation = dailyPrescriptionRation
    }
}
