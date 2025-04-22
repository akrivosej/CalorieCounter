//
//  MainDomainModel.swift
//  AINutritionist
//
//  Created by muser on 26.03.2025.
//

import Foundation
import RealmSwift

struct MainDomainModel {
    var id: UUID
    var creationDate: Date
    var waterBalance: Double
    var kklBalance: Double
    var dailyRation: List<DailyRationDomainModel>
    var dailyPrescriptionRation: List<DailyPrescriptionRationDomainModel>

    init(
        id: UUID = .init(),
        creationDate: Date = .init(),
        waterBalance: Double = 0,
        kklBalance: Double = 0,
        dailyRation: List<DailyRationDomainModel>,
        dailyPrescriptionRation: List<DailyPrescriptionRationDomainModel>
    ) {
        self.id = id
        self.creationDate = creationDate
        self.waterBalance = waterBalance
        self.kklBalance = kklBalance
        self.dailyRation = dailyRation
        self.dailyPrescriptionRation = dailyPrescriptionRation
    }
}
