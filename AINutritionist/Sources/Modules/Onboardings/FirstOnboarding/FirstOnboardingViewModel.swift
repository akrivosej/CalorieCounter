//
//  FirstOnboardingViewModel.swift
//  AINutritionist
//
//  Created by muser on 02.04.2025.
//

import Foundation
import RealmSwift

final class FirstOnboardingViewModel: ObservableObject {
    func loadData() {
        let storage: ModelStorage = .init()
        
        guard storage.read().isEmpty else { return }

        storage.store(item: .init(creationDate: .init(), waterBalance: 0, kklBalance: 0, dailyRation: .init(), dailyPrescriptionRation: .init()))
    }
}
