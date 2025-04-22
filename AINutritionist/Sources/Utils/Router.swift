//
//  Router.swift
//  AINutritionist
//
//  Created by muser on 25.03.2025.
//

import Foundation

enum Router: Hashable {
    case secondOnboarding
    case thirdOnboarding
    case fouthOnboadring
    case dataProcessing
    case weightDataCollection
    case heightDataCollection
    case ageDataCollection
    case physicalLevelDataCollection
    case foodPreferencesDataCollection
    case allergiesDataCollection
    case weightTargetDataCollection
    case deadlineDataCollection
    case main
    case menu
    case menuDetails(MenuItemViewModel)
    case chat
    case stats
    case account
    case tabBarView
    case allirgiesList
    case root
    case registration
}
