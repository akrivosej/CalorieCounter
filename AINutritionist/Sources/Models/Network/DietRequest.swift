//
//  DietRequest.swift
//  AINutritionist
//
//  Created by muser on 01.04.2025.
//

import Foundation

struct DietRequest: Codable {
    let deadline: String
    let height: String
    let allergies: String
    let listAllegries: String
    let age: String
    let foodPreferences: String
    let weightTarget: String
    let physicalLevel: String
    let weight: String
}
