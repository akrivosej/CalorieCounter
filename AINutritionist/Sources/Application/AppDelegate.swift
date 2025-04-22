//
//  AppDelegate.swift
//  AINutritionist
//
//  Created by muser on 27.02.2025.
//

import UIKit
import AppTrackingTransparency
import FirebaseCore
import AppsFlyerLib
import TelemetryDeck
import RevenueCat
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        let config = TelemetryDeck.Config(appID: "EDCE133E-5AAD-48FB-958C-E252D4088520")
        TelemetryDeck.initialize(config: config)
        AppsFlyerLib.shared().appsFlyerDevKey = "ebfiNxBdD4uCdoXjV9Th7F"
        AppsFlyerLib.shared().appleAppID = "6744904660"
        AppsFlyerLib.shared().delegate = self
        
        
//        Purchases.logLevel = .debug
//        Purchases.configure(
//            withAPIKey: "appl_rwMiEqQxqedmLVQzGEYipnKpWDY",
//            appUserID: nil
//        )
//                
//        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
//            if let error = error {
//                print("Помилка ініціалізації RevenueCat: \(error)")
//            } else {
//                print("RevenueCat успішно ініціалізовано \(purchaserInfo)")
//            }
//        }
//        
//        Purchases.shared.getOfferings { offerings, error in
//            if let offerings = offerings {
//                // Тут перевірте, що отримуєте пропозиції
//                print("Offerings: \(offerings)")
//            }
//        }
        
        Purchases.logLevel = .debug
            
            Purchases.configure(withAPIKey: "appl_FKkheblyOLWuMpZthkmswbPeRNz")
            
            // Перевіряємо, чи користувач авторизований
            if let userId = Auth.auth().currentUser?.uid {
                // Якщо так, логінимо його в RevenueCat
                Purchases.shared.logIn(userId) { purchaserInfo, created, error in
                    if let error = error {
                        print("Помилка логіну в RevenueCat: \(error.localizedDescription)")
                    } else {
                        print("Користувач успішно залогінений в RevenueCat")
                        
                        // Перевіряємо статус підписки
                        if purchaserInfo?.entitlements["Subscription"]?.isActive == true {
                            SubscriptionManager.shared.setSubscriptionStatus(true)
                        }
                    }
                }
            }
        
        AppsFlyerLib.shared().start()
        
        return true
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: any Error) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Проверяем статус авторизации перед запросом
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                // Удаляем waitForATTUserAuthorization, так как это может вызывать задержку
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    DispatchQueue.main.async {
                        AppsFlyerLib.shared().start()
                    }
                }
            } else {
                AppsFlyerLib.shared().start()
            }
        } else {
            // Для iOS ниже 14
            AppsFlyerLib.shared().start()
        }
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
//        ATTrackingManager.requestTrackingAuthorization { (status) in
//            switch status {
//            case .authorized:
//                print("authorized")
//            case .denied:
//                print("denied")
//            case .notDetermined:
//                print("Not Determined")
//            case .restricted:
//                print("Restricted")
//            @unknown default:
//                print("Unknown")
//            }
//        }
//        AppsFlyerLib.shared().start()
//    }
    
//
//     MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
}
