//
//  RealmStorage.swift
//  AINutritionist
//
//  Created by muser on 26.03.2025.
//

import Foundation
import RealmSwift

struct RealmStorage {
    static let shared: RealmStorage = .init()
    
    private let config = Realm.Configuration(schemaVersion: 1)
    
    let realm: Realm?
    
    private init() {
        Realm.Configuration.defaultConfiguration = config
        do {
            self.realm = try Realm()
        } catch {
            print("Error: Failed to create realm, reason: \(error.localizedDescription)")
            self.realm = nil
        }
    }
    
    // MARK: - Create
    func create<T: Object>(object: T) {
        guard let realm = self.realm else { return }
        
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("Failed write to realm, reason: \(error.localizedDescription)")
        }
    }
    
    func create<T: Object>(objects: [T]) {
        guard let realm = self.realm else { return }
        
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch {
            print("Failed write to realm, reason: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update
    func update(action: () -> Void) {
        guard let realm else { return }
        
        do {
            try realm.write {
                action()
            }
        } catch {
            print("Failed to update Realm, reason: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Read
    func read<T: Object>(type: T.Type) -> Results<T>? {
        guard let realm = self.realm else { return nil }
        
        return realm.objects(T.self)
    }
    
    // MARK: - Delete
    func delete<T: Object>(object: T) {
        guard let realm else { return }
        
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Failed delete from realm, reason: \(error.localizedDescription)")
        }
    }
    
    func delete<T: Object>(objects: [T]) {
        guard let realm else { return }
        
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            print("Failed delete from realm, reason: \(error.localizedDescription)")
        }
    }
    
    func delete<T: Object>(type: T.Type, where isIncluded: (Query<T>) -> Query<Bool>) {
        guard let realm else { return }
        
        delete(objects: realm.objects(T.self).where(isIncluded).map({ $0 }))
    }
}
