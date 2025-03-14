//
//  KeyManager.swift
//  iChat
//
//  Created by Marta Miozga on 15/12/2024.
//

import Foundation
import SignalProtocol

/// Klasa zarządzająca kluczami dla Signal Protocol
class KeyManager {

    static let shared = KeyManager()

    private init() {}

   
    /// Sprawdza brakujące klucze podczas logowania i generuje je, jeśli są potrzebne.
 
       func initializeKeys(for store: SignalKeyStore, preKeyCount: Int = 10) throws {
           print("Rozpoczynanie sprawdzania i generowania brakujących kluczy...")

           if (try? store.identityKeyStore.getIdentityKeyData()) == nil {
                 print("IdentityKey nie istnieje. Inicjalizacja nowego `InMemoryIdentityKeyStore`.")
                 store.identityKeyStore = try InMemoryIdentityKeyStore()
             } else {
                 print("IdentityKey już istnieje.")
             }

           // Generuj PreKeys przed SignedPreKey
           print("Sprawdzanie PreKeys...")
           try initializePreKeys(for: store, count: preKeyCount)

           print("Sprawdzanie SignedPreKey...")
           try initializeSignedPreKey(for: store)

           print("Sprawdzanie i generowanie brakujących kluczy zakończone.")
           
  
       }


    
    /// Generuje podpisany PreKey.
    private func initializeSignedPreKey(for store: SignalKeyStore) throws {
        guard let signedPreKeyStore = store.signedPreKeyStore as? InMemorySignedPreKeyStore else {
            throw SignalError(.storageError, "Nieprawidłowy typ magazynu SignedPreKeyStore")
        }

        // Synchronizuj ostatni ID
        signedPreKeyStore.synchronizeLastId()

        // Wyznacz ID nowego klucza
        var newId: UInt32 = signedPreKeyStore.lastId + 1
        if signedPreKeyStore.lastId == 0 {
            print("Magazyn SignedPreKeys jest pusty. Generowanie pierwszego SignedPreKey z ID: 1")
            newId = 1
        }

        // Obsługa przepełnienia ID
        if newId > UInt32.max {
            newId = 1
        }

        // Pobierz klucz prywatny IdentityKey
        let identityPrivateKey = try store.identityKeyStore.getIdentityPrivateKey()
        print("Pobrano klucz prywatny IdentityKey")

        // Generacja i zapis SignedPreKey
        do {
            let signedPreKey = try SignalCrypto.generateSignedPreKey(identityKey: identityPrivateKey, id: newId)
            let serializedSignedPreKey = try signedPreKey.protoData()

            guard serializedSignedPreKey.count > 0 else {
                print("Błąd: Rozmiar SignedPreKey wynosi 0 bajtów.")
                throw SignalError(.invalidKey, "Nieprawidłowy rozmiar SignedPreKey: \(serializedSignedPreKey.count) bajtów")
            }

            print("SignedPreKey wygenerowany. Rozmiar: \(serializedSignedPreKey.count) bajtów.")
            try signedPreKeyStore.store(signedPreKey: serializedSignedPreKey, for: newId)
            signedPreKeyStore.lastId = newId
            print("SignedPreKey zapisany dla ID: \(newId)")

        } catch {
            print("Błąd podczas generowania SignedPreKey: \(error.localizedDescription)")
            throw SignalError(.storageError, "Błąd podczas inicjalizacji SignedPreKey: \(error.localizedDescription)")
        }
    }




    // Generuje PreKeys.
    private func initializePreKeys(for store: SignalKeyStore,  count: Int) throws {
        guard let preKeyStore = store.preKeyStore as? InMemoryPreKeyStore else {
            throw SignalError(.storageError, "Nieprawidłowy typ magazynu PreKeyStore")
        }

        // Synchronizuj ostatni ID przed generowaniem nowych kluczy
        preKeyStore.synchronizeLastId()
        var startId = preKeyStore.lastId + 1

        // Obsługa przepełnienia ID
        if startId > UInt32.max {
            startId = 1
        }

        // Oblicz brakujące klucze do osiągnięcia limitu
        let maxKeys = 10
        let existingKeys = preKeyStore.numberOfExistingKeys()
        let keysToGenerate = min(count, maxKeys - existingKeys)

        if keysToGenerate <= 0 {
            print("Nie trzeba generować nowych PreKeys. Limit \(maxKeys) już osiągnięty.")
            return
        }

        print("Generowanie PreKeys od ID: \(startId) (ilość: \(keysToGenerate))...")
        let preKeys = try SignalCrypto.generatePreKeys(start: startId, count: keysToGenerate)

        var preKeysToSave: [UInt32: Data] = [:]

        for preKey in preKeys {
            let serializedPreKey = try preKey.protoData()
            try preKeyStore.store(preKey: serializedPreKey, for: preKey.publicKey.id)
            preKeysToSave[preKey.publicKey.id] = serializedPreKey
            print("PreKey zapisany z ID: \(preKey.publicKey.id), rozmiar danych: \(serializedPreKey.count) bajtów")
        }

        print("Generowanie PreKeys zakończone.")
    }
}
