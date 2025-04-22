//
//  SubscriptionViewModel.swift
//  AINutritionist
//
//  Created by muser on 31.03.2025.
//

import Foundation
import SwiftUI
import RevenueCat
import StoreKit
import FirebaseAuth

class SubscriptionViewModel: ObservableObject {
    @Published var packages: [Package] = []
    @Published var isLoading: Bool = false
    @Published var selectedPackageIndex: Int = 0
    
    // Загрузка доступных подписок
    func loadSubscriptions() {
        isLoading = true
        
//        // Використовуємо FetchOptions для кращої роботи зі StoreKit
//        let fetchOptions = FetchOptions()
//        fetchOptions.cachePolicy = .fetchAndReplaceLocalData
        
        Purchases.shared.getOfferings() { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Перевіряємо, чи можемо продовжити, використовуючи кешовані дані
                    if let purchasesError = error as? RevenueCat.ErrorCode,
                       purchasesError == .offlineConnectionError || purchasesError == .configurationError {
                        // Спробуємо використати кешовані дані або StoreKit напряму
                        self?.tryLoadCachedOfferings()
                    } else {
                        self?.isLoading = false
                        self?.showAlert(title: "Error", message: "Failed to load subscriptions: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let offerings = offerings, let currentOffering = offerings.current else {
                    // Якщо офферінги порожні, пробуємо використати StoreKit напряму
                    self?.tryLoadCachedOfferings()
                    return
                }
                
                // Успішно отримали дані
                self?.processOfferings(currentOffering)
            }
        }
    }
    
    // Метод для завантаження кешованих офферінгів
    private func tryLoadCachedOfferings() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showAlert(title: "Information", message: "Subscriptions are unavailable at the moment. Check your internet connection or try again later.")
                    // Встановлюємо заглушки для тестування
                    self?.setFallbackPackages()
                    return
                }
                
                guard let offerings = offerings, let currentOffering = offerings.current else {
                    self?.showAlert(title: "Information", message: "Subscriptions are unavailable at the moment")
                    // Встановлюємо заглушки для тестування
                    self?.setFallbackPackages()
                    return
                }
                
                // Обробляємо отримані офферінги
                self?.processOfferings(currentOffering)
            }
        }
    }
    
    // Обробка отриманих офферінгів і фільтрація пакетів
    private func processOfferings(_ offering: Offering) {
        // Спочатку перевіряємо наявність річного та місячного пакетів
        var annualPackage: Package? = nil
        var monthlyPackage: Package? = nil
        
        // Шукаємо потрібні пакети за типом
        for package in offering.availablePackages {
            if package.packageType == .annual {
                annualPackage = package
            } else if package.packageType == .monthly {
                monthlyPackage = package
            }
        }
        
        // Якщо не знайшли якийсь із пакетів, шукаємо за ідентифікатором продукту
        if annualPackage == nil || monthlyPackage == nil {
            for package in offering.availablePackages {
                let productId = package.storeProduct.productIdentifier
                if annualPackage == nil && (productId.contains("annual") || productId.contains("year")) {
                    annualPackage = package
                } else if monthlyPackage == nil && productId.contains("month") {
                    monthlyPackage = package
                }
            }
        }
                
                // Формуємо масив пакетів
                var filteredPackages: [Package] = []
                if let annual = annualPackage {
                    filteredPackages.append(annual)
                }
                if let monthly = monthlyPackage {
                    filteredPackages.append(monthly)
                }
                
                // Якщо не знайшли необхідні пакети, використовуємо всі доступні
                if filteredPackages.isEmpty {
                    filteredPackages = offering.availablePackages
                }
                
                self.packages = filteredPackages
                self.isLoading = false
            }
            
            // Встановлюємо заглушки для тестування інтерфейсу
            private func setFallbackPackages() {
                // Ця функція викликається тільки для тестування, коли не вдалося отримати реальні пакети
                // В релізній версії цей код можна видалити
                print("Using fallback packages for testing UI")
            }
            
            // Покупка выбранного пакета
            func purchaseSelectedPackage(completion: @escaping (Bool) -> Void) {
                guard !packages.isEmpty, selectedPackageIndex < packages.count else {
                    showAlert(title: "Error", message: "Subscription package not selected")
                    completion(false)
                    return
                }
                
                let package = packages[selectedPackageIndex]
                isLoading = true
                
                Purchases.shared.purchase(package: package) { [weak self] transaction, purchaserInfo, error, userCancelled in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if userCancelled {
                            print("Користувач скасував покупку")
                            completion(false)
                            return
                        }
                        
                        if let error = error {
                            // Додаткова обробка помилок StoreKit
                            if let storeKitError = error as? SKError {
                                switch storeKitError.code {
                                case .paymentCancelled:
                                    print("Користувач скасував покупку")
                                    completion(false)
                                    return
                                case .paymentInvalid:
                                    self?.showAlert(title: "Error", message: "Incorrect payment information. Please try again.")
                                case .paymentNotAllowed:
                                    self?.showAlert(title: "Error", message: "This device cannot make payments.")
                                case .storeProductNotAvailable:
                                    self?.showAlert(title: "Error", message: "Product not available in your region.")
                                default:
                                    self?.showAlert(title: "Error", message: "Failed to complete the purchase: \(error.localizedDescription)")
                                }
                            } else if let purchasesError = error as? RevenueCat.ErrorCode {
                                switch purchasesError {
                                case .networkError:
                                    self?.showAlert(title: "Network error", message: "Check your internet connection and try again.")
                                case .purchaseCancelledError:
                                    print("Користувач скасував покупку")
                                    completion(false)
                                    return
                                default:
                                    self?.showAlert(title: "Error", message: "Failed to complete the purchase: \(error.localizedDescription)")
                                }
                            } else {
                                self?.showAlert(title: "Error", message: "Failed to complete the purchase: \(error.localizedDescription)")
                            }
                            completion(false)
                            return
                        }
                        
                        guard let purchaserInfo = purchaserInfo else {
                            completion(false)
                            return
                        }
                        
                        // Проверка статуса подписки
                        if purchaserInfo.entitlements["Subscription"]?.isActive == true {
                            self?.showAlert(title: "Success!", message: "You have successfully subscribed! Thank you for your support.")
                                                completion(true)
                                            } else {
                                                completion(false)
                                            }
                                        }
                                    }
                                }
    
        // Восстановление покупок
    
//    func restorePurchases(completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        
//        Purchases.shared.restorePurchases { [weak self] (purchaserInfo, error) in
//            guard let self else { return }
//            
//            if purchaserInfo?.entitlements.all["Subscription"]?.isActive == true {
//                UserDefaults.standard.set(true, forKey: "isSubscriptionPurchased")
//                UserDefaults.standard.synchronize()
//                self.showAlert(title: "Успіх", message: "Ваші підписки успішно відновлено!")
//                completion(true)
//              //          self.dismiss(animated: true)
//                }
//          }
//    }
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        // Якщо користувач авторизований, використовуємо його ID для логіну в RevenueCat
        if let userId = Auth.auth().currentUser?.uid {
            Purchases.shared.logIn(userId) { [weak self] (purchaserInfo, created, error) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.showAlert(title: "Error", message: "Failed to restore purchases: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    if purchaserInfo?.entitlements["Subscription"]?.isActive == true {
                        // Зберігаємо статус підписки
                        UserDefaults.standard.set(true, forKey: "isSubscriptionPurchased")
                        UserDefaults.standard.synchronize()
                        SubscriptionManager.shared.setSubscriptionStatus(true)
                        
                        self?.showAlert(title: "Success", message: "Your subscriptions have been successfully restored!")
                        completion(true)
                    } else {
                        self?.performStandardRestore(completion: completion)
                    }
                }
            }
        } else {
            performStandardRestore(completion: completion)
        }
    }
    
    private func performStandardRestore(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] purchaserInfo, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to restore purchases: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if purchaserInfo?.entitlements["Subscription"]?.isActive == true {
                    UserDefaults.standard.set(true, forKey: "isSubscriptionPurchased")
                    UserDefaults.standard.synchronize()
                    SubscriptionManager.shared.setSubscriptionStatus(true)
                    
                    self?.showAlert(title: "Success", message: "Your subscriptions have been successfully restored!")
                    completion(true)
                } else {
                    self?.showAlert(title: "Information", message: "No active subscriptions found.")
                    completion(false)
                }
            }
        }
    }
                                
    func getPackageTypeDescription(_ packageType: PackageType) -> String {
        switch packageType {
        case .monthly:
            return "Щомісячна підписка"
        case .annual:
            return "Річна підписка"
        case .lifetime:
            return "Довічна підписка"
        case .weekly:
            return "Тижнева підписка"
        case .sixMonth:
            return "Підписка на 6 місяців"
        case .threeMonth:
            return "Підписка на 3 місяці"
        case .twoMonth:
            return "Підписка на 2 місяці"
        case .custom:
            return "Спеціальна пропозиція"
        case .unknown:
            return "Підписка"
        @unknown default:
            return "Підписка"
        }
    }
}

//class SubscriptionViewModel: ObservableObject {
//    @Published var packages: [Package] = []
//    @Published var isLoading: Bool = false
//    @Published var selectedPackageIndex: Int = 0
//    
//    // Загрузка доступных подписок
//    func loadSubscriptions() {
//        isLoading = true
//        
//        Purchases.shared.getOfferings { [weak self] offerings, error in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                if let error = error {
//                    self?.showAlert(title: "Помилка", message: "Не вдалося завантажити підписки: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let offerings = offerings, let currentOffering = offerings.current else {
//                    self?.showAlert(title: "Інформація", message: "Підписки недоступні в даний момент")
//                    return
//                }
//                
//                // Фильтрация пакетов для отображения только годовой и полугодовой подписок
//                let filteredPackages = currentOffering.availablePackages.filter { package in
//                    return package.packageType == .annual || package.packageType == .sixMonth
//                }
//                
//                self?.packages = filteredPackages
//            }
//        }
//    }
//    
//    // Покупка выбранного пакета
//    func purchaseSelectedPackage(completion: @escaping (Bool) -> Void) {
//        guard !packages.isEmpty, selectedPackageIndex < packages.count else {
//            showAlert(title: "Помилка", message: "Пакет підписки не вибрано")
//            completion(false)
//            return
//        }
//        
//        let package = packages[selectedPackageIndex]
//        isLoading = true
//        
//        Purchases.shared.purchase(package: package) { [weak self] transaction, purchaserInfo, error, userCancelled in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                if userCancelled {
//                    print("Користувач скасував покупку")
//                    completion(false)
//                    return
//                }
//                
//                if let error = error {
//                    self?.showAlert(title: "Помилка", message: "Не вдалося здійснити покупку: \(error.localizedDescription)")
//                    completion(false)
//                    return
//                }
//                
//                guard let purchaserInfo = purchaserInfo else {
//                    completion(false)
//                    return
//                }
//                
//                // Проверка статуса подписки
//                if purchaserInfo.entitlements["premium"]?.isActive == true {
//                    self?.showAlert(title: "Успіх!", message: "Ви успішно оформили підписку! Дякуємо за підтримку.")
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            }
//        }
//    }
//    
//    // Получение описания типа пакета на украинском
//    func getPackageTypeDescription(_ packageType: PackageType) -> String {
//        switch packageType {
//        case .monthly:
//            return "Щомісячна підписка"
//        case .annual:
//            return "Річна підписка"
//        case .lifetime:
//            return "Довічна підписка"
//        case .weekly:
//            return "Тижнева підписка"
//        case .sixMonth:
//            return "Підписка на 6 місяців"
//        case .threeMonth:
//            return "Підписка на 3 місяці"
//        case .twoMonth:
//            return "Підписка на 2 місяці"
//        case .custom:
//            return "Спеціальна пропозиція"
//        case .unknown:
//            return "Підписка"
//        @unknown default:
//            return "Підписка"
//        }
//    }
//}
