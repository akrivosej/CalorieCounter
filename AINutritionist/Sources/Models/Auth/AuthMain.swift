//
//  AuthMain.swift
//  AINutritionist
//
//  Created by muser on 02.04.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import RevenueCat

protocol AuthCoreProtocol {
    var isFormValid: Bool { get }
}

@MainActor
class AuthMain: ObservableObject {
    @Published var text: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentuser: User?
    @Published var isNewUser = false
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
            
            // Якщо користувач вже авторизований, синхронізуємо з RevenueCat
            if let uid = userSession?.uid {
                await syncRevenueCatUser(userId: uid)
            }
        }
    }
    
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - RevenueCat інтеграція
    
    /// Синхронізує користувача Firebase з RevenueCat
    func syncRevenueCatUser(userId: String) async {
        return await withCheckedContinuation { continuation in
            Purchases.shared.logIn(userId) { (purchaserInfo, created, error) in
                if let error = error {
                    print("Помилка синхронізації з RevenueCat: \(error.localizedDescription)")
                } else {
                    print("Користувач успішно синхронізований з RevenueCat. AppUserID: \(Purchases.shared.appUserID)")
                    
                    // Перевіряємо підписки користувача
                    if purchaserInfo?.entitlements["Subscription"]?.isActive == true {
                        // У користувача є активна підписка
                        SubscriptionManager.shared.setSubscriptionStatus(true)
                    }
                }
                continuation.resume()
            }
        }
    }
    
    /// Відключає користувача від RevenueCat при виході
    func logoutFromRevenueCat() {
        Purchases.shared.logOut { _, error in
            if let error = error {
                print("Помилка виходу з RevenueCat: \(error.localizedDescription)")
            } else {
                print("Успішний вихід з RevenueCat")
            }
        }
    }
    
    // MARK: - Firebase Authentication
    
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            isNewUser = true
            self.userSession = result.user
            print("Signed in anonymously as user: \(String(describing: result.user.uid))")
            
            // Синхронізуємо з RevenueCat
            await syncRevenueCatUser(userId: result.user.uid)
        } catch {
            text = "Error signing in anonymously: \(error.localizedDescription)"
            print("Error signing in anonymously: \(error.localizedDescription)")
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            
            // Синхронізуємо з RevenueCat після входу
            await syncRevenueCatUser(userId: result.user.uid)
        } catch {
            text = "Error login: \(error.localizedDescription)"
            print("Error login: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, name: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            isNewUser = true
            self.userSession = result.user
            
            let user = User(id: result.user.uid, name: name, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            print("User saved: \(user)")
            
            await fetchUser()
            
            // Синхронізуємо з RevenueCat після реєстрації
            await syncRevenueCatUser(userId: result.user.uid)
        } catch {
            text = "Error create user: \(error.localizedDescription)"
            print(error.localizedDescription)
            throw error
        }
    }
    
    func deleteUserAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "UserErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])))
            return
        }
        
        // Спочатку виходимо з RevenueCat
        logoutFromRevenueCat()
        // Очищаємо локальний статус підписки
        UserDefaults.standard.removeObject(forKey: "isSubscriptionPurchased")
        UserDefaults.standard.synchronize()
        
        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.isNewUser = false
                completion(.success(()))
            }
        }
    }
    
    func signOut() {
        do {
            // Виходимо з RevenueCat перед виходом з Firebase
            logoutFromRevenueCat()
            
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentuser = nil
            isNewUser = false
            
            // Очищаємо локальний статус підписки
            UserDefaults.standard.removeObject(forKey: "isSubscriptionPurchased")
            UserDefaults.standard.synchronize()
        } catch {
            text = "Error signout: \(error.localizedDescription)"
            print("Error signout: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentuser = try snapshot.data(as: User.self)
            print("Fetched User: \(String(describing: self.currentuser))")
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
}
