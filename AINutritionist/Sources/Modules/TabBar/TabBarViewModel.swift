//
//  TabBarViewModel.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import Foundation

class TabBarViewModel: ObservableObject {
    @Published var current = "home"
    @Published var isTabBarShown = true
}
