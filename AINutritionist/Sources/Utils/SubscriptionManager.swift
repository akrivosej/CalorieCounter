//
//  SubscriptionManager.swift
//  AINutritionist
//
//  Created by muser on 07.04.2025.
//


import Foundation
import RevenueCat

class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    private init() {}
    
    // Перевіряє, чи є у користувача преміум-підписка
    func checkPremiumAccess(completion: @escaping (Bool) -> Void) {
        // Спочатку перевіряємо локальний статус
        if UserDefaults.standard.bool(forKey: "isSubscriptionPurchased") {
            completion(true)
            return
        }
        
        // Якщо локально не знайдено, перевіряємо у RevenueCat
        Purchases.shared.getCustomerInfo { purchaserInfo, error in
            let hasPremium = purchaserInfo?.entitlements["Subscription"]?.isActive == true
            
            // Зберігаємо статус локально, якщо він позитивний
            if hasPremium {
                self.setSubscriptionStatus(true)
            }
            
            completion(hasPremium)
        }
    }
    
    // Додайте слухача для відстеження змін у статусі підписки
    func observePremiumStatus(with listener: @escaping (Bool) -> Void) {
        // Слухаємо зміни від RevenueCat
        NotificationCenter.default.addObserver(
            forName: Notification.Name("PurchasesSubscriptionStatusUpdated"),
            object: nil,
            queue: .main
        ) { notification in
            self.checkPremiumAccess(completion: listener)
        }
        
        // Слухаємо локальні зміни статусу
        NotificationCenter.default.addObserver(
            forName: Notification.Name("SubscriptionStatusChanged"),
            object: nil,
            queue: .main
        ) { notification in
            if let hasPremium = notification.userInfo?["hasPremium"] as? Bool {
                listener(hasPremium)
            } else {
                self.checkPremiumAccess(completion: listener)
            }
        }
    }
    
    // Метод для збереження статусу підписки
    func setSubscriptionStatus(_ isPremium: Bool) {
        UserDefaults.standard.set(isPremium, forKey: "isSubscriptionPurchased")
            
        // Зберігаємо поточний AppUserID для крос-девайс відновлення
        if isPremium {
            let appUserID = Purchases.shared.appUserID
            UserDefaults.standard.set(appUserID, forKey: "revenueCatAppUserID")
        }
        
        UserDefaults.standard.synchronize()
        
        // Надсилаємо сповіщення для оновлення UI у всьому додатку
        NotificationCenter.default.post(
            name: Notification.Name("SubscriptionStatusChanged"),
            object: nil,
            userInfo: ["hasPremium": isPremium]
        )
    }
    
    // Метод для відновлення покупок
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] purchaserInfo, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Restore error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if purchaserInfo?.entitlements["Subscription"]?.isActive == true {
                // Зберігаємо статус підписки та AppUserID
                self.setSubscriptionStatus(true)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Метод для принудительного обновления статуса подписки
    func refreshPremiumStatus(completion: @escaping (Bool) -> Void = { _ in }) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self = self else { return }
            
            let hasPremium = customerInfo?.entitlements["Subscription"]?.isActive == true
            
            // Оновлюємо локальний статус
            if hasPremium {
                self.setSubscriptionStatus(true)
            }
            
            completion(hasPremium)
        }
    }
    
    // При виході з акаунта (якщо це потрібно)
    func logout() {
        UserDefaults.standard.removeObject(forKey: "isSubscriptionPurchased")
        UserDefaults.standard.removeObject(forKey: "revenueCatAppUserID")
        UserDefaults.standard.synchronize()
        
        // Оновлюємо користувача в RevenueCat
        Purchases.shared.logOut { _, _ in }
    }
}


//class SubscriptionManager {
//    static let shared = SubscriptionManager()
//    
//    private init() {}
//    
//    // Перевіряє, чи є у користувача преміум-підписка
//    func checkPremiumAccess(completion: @escaping (Bool) -> Void) {
//        Purchases.shared.getCustomerInfo { purchaserInfo, error in
//            let hasPremium = purchaserInfo?.entitlements["Subscription"]?.isActive == true
//            completion(hasPremium)
//        }
//    }
//    
//    // Додайте слухача для відстеження змін у статусі підписки
//    func observePremiumStatus(with listener: @escaping (Bool) -> Void) {
//        // В зависимости от версии RevenueCat, используйте соответствующий метод
//        // для наблюдения за изменениями статуса подписки
//        NotificationCenter.default.addObserver(
//            forName: Notification.Name("PurchasesSubscriptionStatusUpdated"),
//            object: nil,
//            queue: .main
//        ) { notification in
//            self.checkPremiumAccess(completion: listener)
//        }
//    }
//    
//    // Метод для принудительного обновления статуса подписки
//    func refreshPremiumStatus(completion: @escaping (Bool) -> Void = { _ in }) {
//        // Используем .forceFetch если доступно, или просто обычный getCustomerInfo
//        Purchases.shared.getCustomerInfo { customerInfo, error in
//            let hasPremium = customerInfo?.entitlements["Subscription"]?.isActive == true
//            completion(hasPremium)
//        }
//    }
//}
