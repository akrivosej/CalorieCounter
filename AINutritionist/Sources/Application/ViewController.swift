//
//  ViewController.swift
//  AINutritionist
//
//  Created by muser on 27.02.2025.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        //SubscriptionsViewController
//        let onboardingScreen = SubscriptionsViewController()
////        let onboardingScreen = FirstOnboardingScreen(viewModel: .init())
////        let hostingController = UIHostingController(rootView: onboardingScreen)
//        
//        addChild(onboardingScreen)
//        view.addSubview(onboardingScreen.view)
////        addChild(hostingController)
////        view.addSubview(hostingController.view)
////        hostingController.didMove(toParent: self)
//        
//        onboardingScreen.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            onboardingScreen.view.topAnchor.constraint(equalTo: view.topAnchor),
//            onboardingScreen.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            onboardingScreen.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            onboardingScreen.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
        
//        //SubscriptionsViewController
//        let onboardingScreen = SubscriptionsViewController()
        let onboardingScreen = FirstOnboardingScreen(viewModel: .init())
        let hostingController = UIHostingController(rootView: onboardingScreen)
        
//        addChild(onboardingScreen)
//        view.addSubview(onboardingScreen.view)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
