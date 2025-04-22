//
//  User.swift
//  AINutritionist
//
//  Created by muser on 02.04.2025.
//

import Foundation
import SwiftUI

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
}
