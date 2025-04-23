//
//  AccountViewModel.swift
//  AINutritionist
//
//  Created by muser on 21.03.2025.
//

import Foundation

final class AccountViewModel: ObservableObject {
    
    func deleteAcc() {
        let storage: ModelStorage = .init()
        storage.deleteAll()
    }
}
