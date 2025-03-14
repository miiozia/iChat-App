//
//  RealmMessage.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import RealmSwift
import Security

class RealmMessageManager {
    static let shared = RealmMessageManager()
 let realm = try! Realm()
    
    private init() {}
    
    func saveInRealm<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .all)
                print(Realm.Configuration.defaultConfiguration.fileURL ?? "Brak ścieżki do pliku Realm")
            }
        } catch {
            print("Error saving realm object", error.localizedDescription)
        }
    }
}







