//
//  SignalKeyStore.swift
//  iChat
//
//  Created by Marta Miozga on 15/12/2024.
//

import Foundation
import SignalProtocol

/// Typ adresu używany w magazynach Signal
struct SignalAddress: Hashable, Equatable, CustomStringConvertible {
    let name: String
    let deviceId: Int
   
    
    var description: String {
        return "\(name):\(deviceId)"
    }
}


// Minimalna implementacja `KeyStore` dla protokołu Signal
class SignalKeyStore: KeyStore {
    
    static let shared: SignalKeyStore = {
           let instance = SignalKeyStore()
           print("SignalKeyStore został zainicjalizowany.")
           return instance
       }()
    
    var identityKeyStore: InMemoryIdentityKeyStore
    var sessionStore: InMemorySessionStore
    var preKeyStore: any SignalProtocol.PreKeyStore
    var signedPreKeyStore: any SignalProtocol.SignedPreKeyStore
    
    typealias Address = SignalAddress
    typealias IdentityKeyStoreType = InMemoryIdentityKeyStore
    typealias SessionStoreType = InMemorySessionStore

    
    init() {
        do {
            self.identityKeyStore = try InMemoryIdentityKeyStore()
        } catch {
            fatalError("Nie udało się zainicjalizować IdentityKeyStore: \(error.localizedDescription)")
        }
        
        self.preKeyStore = InMemoryPreKeyStore()
        self.signedPreKeyStore = InMemorySignedPreKeyStore()
        self.sessionStore = InMemorySessionStore()
    }
    

}

// Przechowywanie kluczy tożsamości
class InMemoryIdentityKeyStore: IdentityKeyStore {
    typealias Address = SignalAddress
    
    // Przechowywanie zserializowanych danych kluczy tożsamości
     var serializedIdentityKeyData: Data?
    
    // Przechowywanie tożsamości dla poszczególnych adresów
    private var identities: [SignalAddress: Data] = [:]
    
    var identityKeyPair: KeyPair
    var registrationId: UInt32
    
    // Inicjalizacja klasy
    init() throws {
        self.registrationId = UInt32.random(in: 1...UInt32.max)
        
        do {
            // Wygenerowanie zserializowanych danych pary kluczy
            let serializedKeyPairData = try SignalCrypto.generateIdentityKeyPair()
            print("IdentityKey został wygenerowany.")
            
            // Przechowanie zserializowanych danych
            self.serializedIdentityKeyData = serializedKeyPairData
            print("Zserializowane dane IdentityKey zapisane. Rozmiar danych: \(serializedKeyPairData.count) bajtów.")
            
            // Utworzenie obiektu KeyPair na podstawie danych
            self.identityKeyPair = try KeyPair(from: serializedKeyPairData)
            
            print("IdentityKey został poprawnie zainicjalizowany w konstruktorze.")
        } catch {
            print("Błąd podczas inicjalizacji IdentityKeyPair: \(error.localizedDescription)")
            throw SignalError(.storageError, "Nie udało się zainicjalizować IdentityKeyPair.")
        }
    }
    
    // Pobiera dane klucza tożsamości.
    func getIdentityKeyData() throws -> Data {
        guard let serializedData = serializedIdentityKeyData else {
            print("Błąd: Brak zapisanych danych IdentityKey.")
            throw SignalError(.storageError, "Brak danych klucza tożsamości.")
        }
        print("Pobrano dane IdentityKey. Rozmiar: \(serializedData.count) bajtów.")
        return serializedData
    }
    
    
    // Pobiera klucz tożsamości jako `KeyPair`.
    func getIdentityKey() throws -> KeyPair {
        return identityKeyPair
    }
    
    func getIdentityPrivateKey() throws -> PrivateKey {
        return identityKeyPair.privateKey
    }
    
    
    // Pobiera tożsamość dla danego adresu.
    func identity(for address: SignalAddress) throws -> Data? {
        return identities[address]
    }
    
    // Przechowuje lub usuwa tożsamość dla danego adresu.
    func store(identity: Data?, for address: SignalAddress) throws {
        if let identity = identity {
            print("Przechowywanie IdentityKey dla adresu \(address.name). Rozmiar: \(identity.count) bajtów.")
            identities[address] = identity
        } else {
            print("Usuwanie IdentityKey dla adresu \(address.name).")
            identities.removeValue(forKey: address)
        }
    }
    
    func getIdentityKeyPair() -> KeyPair {
        return self.identityKeyPair
    }
    
    func validateIdentityKey() throws -> PublicKey {
        print("[INFO] Rozpoczynanie walidacji IdentityKey...")
        do {
            let identityKeyData = try getIdentityKeyData()

            guard identityKeyData.count >= 32 else {
                throw SignalError(.invalidKey, "IdentityKey ma nieprawidłowy rozmiar: \(identityKeyData.count) bajtów.")
            }

            let identityKeyPairObject = try KeyPair(from: identityKeyData)
            print("[INFO] IdentityKey przeszedł wstępną walidację jako KeyPair.")

            // Próba uzyskania publicznego klucza
            let publicKeyData = identityKeyPairObject.publicKey.data
        

            // Próba deserializacji publicznego klucza
            let publicKeyObject = try PublicKey(from: publicKeyData)
            return publicKeyObject
        } catch {
            print("[ERROR] Błąd podczas walidacji IdentityKey: \(error.localizedDescription)")
            throw SignalError(.invalidKey, "Błąd podczas walidacji IdentityKey: \(error.localizedDescription)")
        }
    }


}


// Przechowywanie PreKeys
class InMemoryPreKeyStore: PreKeyStore {
    var preKeys: [UInt32: Data] = [:]
    var lastId: UInt32 = 0
    
    
  
    
    func preKey(for id: UInt32) throws -> Data {
        guard let preKey = preKeys[id] else {
            throw SignalError(.invalidId, "Brak PreKey dla ID: \(id)")
        }
        return preKey
    }
    
    func store(preKey: Data, for id: UInt32) throws {
        print("Dodawanie PreKey z ID \(id). Rozmiar klucza: \(preKey.count) bajtów.")
           
           guard id > 0 && id <= UInt32.max else {
               throw SignalError(.invalidId, "Nieprawidłowe ID PreKey: \(id).")
           }
           
           guard !containsPreKey(for: id) else {
               throw SignalError(.storageError, "PreKey o ID \(id) już istnieje.")
           }
           
           guard preKey.count >= 32 else {
               throw SignalError(.invalidKey, "Nieprawidlowy PreKey. Oczekiwano 32 bajty, otrzymano \(preKey.count).")
           }
           
           preKeys[id] = preKey
           lastId = max(lastId, id) // Aktualizacja lastId
           print("PreKey zapisany z ID: \(id).")
    }
    
    func containsPreKey(for id: UInt32) -> Bool {
        return preKeys[id] != nil
    }
    
    func removePreKey(for id: UInt32) throws {
        guard preKeys.removeValue(forKey: id) != nil else {
            throw SignalError(.storageError, "Nie znaleziono PreKey dla ID: \(id)")
        }
    }
    
    func synchronizeLastId() {
        // Filtruj tylko prawidłowe ID (większe od 0 i mieszczące się w zakresie UInt32)
            let validKeys = preKeys.keys.filter { $0 > 0 && $0 <= UInt32.max }
            
            if validKeys.isEmpty {
                print("Błąd: Magazyn PreKeys jest pusty lub zawiera nieprawidłowe ID. Ustawiono lastId na 0.")
                lastId = 0
            } else {
                lastId = validKeys.max() ?? 0
                print("Synchronized lastId: \(lastId)")
            }
    }

    // Dodaj metodę zwracającą liczbę istniejących kluczy
      func numberOfExistingKeys() -> Int {
          return preKeys.count
      }
    private func generateNEWPreKeys(count: Int) throws {
        var startId = (preKeys.keys.max() ?? 0) + 1

        // Obsługa przepełnienia ID
        if startId > UInt32.max {
            startId = 1
        }

        print("[INFO] Generowanie \(count) PreKeys od ID: \(startId)...")
        let preKeys = try SignalCrypto.generatePreKeys(start: startId, count: count)

        for preKey in preKeys {
            let serializedPreKey = try preKey.protoData()
            try store(preKey: serializedPreKey, for: preKey.publicKey.id)
            print("[INFO] PreKey zapisany z ID: \(preKey.publicKey.id).")
        }

        print("[INFO] Generowanie PreKeys zakończone.")
    }

    
    func validatePreKeys() throws -> SessionPreKeyPublic {
        print("[INFO] Rozpoczynanie walidacji PreKeys...")
        let threshold = 3 // Minimalna liczba kluczy przed generowaniem nowych
            let requiredCount = 10 // Docelowa liczba kluczy w magazynie
        
        // Sprawdź liczbę dostępnych PreKeys
            let existingKeys = preKeys.keys.count
            print("[INFO] Liczba istniejących PreKeys: \(existingKeys). Minimalny próg: \(threshold).")
       
        if existingKeys < threshold {
              // Liczba kluczy poniżej progu, wygeneruj nowe
              let keysToGenerate = requiredCount - existingKeys
              print("[INFO] Generowanie \(keysToGenerate) nowych PreKeys...")
              try generateNEWPreKeys(count: keysToGenerate)
          }

        
        for id in preKeys.keys {
            do {
                print("[DEBUG] Sprawdzanie PreKey o ID: \(id)")

                // Pobierz dane PreKey
                let preKeyData = try preKey(for: id)
                print("[DEBUG] Rozmiar PreKeyData dla ID \(id): \(preKeyData.count) bajtów")

                // Wstępna walidacja jako SessionPreKey
                let sessionPreKey = try SessionPreKey(from: preKeyData)
                print("[INFO] PreKey o ID \(id) przeszedł wstępną walidację jako SessionPreKey.")

                // Pobranie publicznego klucza z IdentityKeyStore
                let identityKey = try SignalKeyStore.shared.identityKeyStore.getIdentityKey()
                let publicKey = identityKey.publicKey
                print("[INFO] Pobranie PublicKey z IdentityKey zakończone sukcesem: \(publicKey).")

                // Tworzenie obiektu SessionPreKeyPublic
                let sessionPreKeyPublic = SessionPreKeyPublic(id: UInt32(id), key: publicKey)
                print("[INFO] PreKey o ID \(id) przeszedł walidację jako SessionPreKeyPublic.")
                
                
                return sessionPreKeyPublic
                

            } catch {
                print("[ERROR] Błąd podczas walidacji PreKey o ID \(id): \(error.localizedDescription)")
            }
        }

        print("[ERROR] Żaden z PreKeys nie przeszedł walidacji.")
        throw SignalError(.invalidKey, "Brak poprawnych PreKeys.")
    }


    
}



// Przechowywanie SignedPreKeys
class InMemorySignedPreKeyStore: SignedPreKeyStore {
    var lastId: UInt32 = 0
    
    // Przechowywanie Signed PreKeys w formie słownika
    private var signedPreKeys: [UInt32: Data] = [:]
    
    
    
    
    // Pobiera Signed PreKey dla podanego ID.
    func signedPreKey(for id: UInt32) throws -> Data {
        guard let preKey = signedPreKeys[id] else {
            print("Błąd: Brak SignedPreKey dla ID: \(id)")
            throw SignalError(.invalidId, "Brak SignedPreKey dla ID: \(id)")
        }
        print("Pobrano SignedPreKey dla ID: \(id): \(preKey.base64EncodedString())")
        return preKey
        
    }
    
    
    // Przechowuje Signed PreKey dla podanego ID.
    func store(signedPreKey: Data, for id: UInt32) throws {
        print("Dodawanie SignedPreKey z ID \(id). Rozmiar klucza: \(signedPreKey.count) bajtów.")
        
        guard id > 0 && id <= UInt32.max else {
            throw SignalError(.invalidId, "Nieprawidłowe ID SignedPreKey: \(id).")
        }
        
        guard try !containsSignedPreKey(for: id) else {
            throw SignalError(.storageError, "SignedPreKey o ID \(id) już istnieje.")
        }
        
        guard signedPreKey.count >= 32 else {
            throw SignalError(.invalidKey, "Nieprawidłowy SignedPreKey. Oczekiwano 32 bajty, otrzymano \(signedPreKey.count).")
        }
        
        signedPreKeys[id] = signedPreKey
        lastId = max(lastId, id) // Aktualizacja lastId
        print("SignedPreKey zapisany z ID: \(id).")
    }
    
    // Synchronizuje lastId z kluczami w magazynie
    func synchronizeLastId() {
        let validKeys = signedPreKeys.keys.filter { $0 > 0 && $0 <= UInt32.max }
        
        if validKeys.isEmpty {
            print("Błąd: Magazyn SignedPreKeys jest pusty. Ustawiono lastId na 0.")
            lastId = 0
        } else {
            lastId = validKeys.max() ?? 0
            print("Synchronized lastId: \(lastId)")
        }
    }
    
    
    
    
    // Sprawdza, czy istnieje Signed PreKey dla podanego ID.
    func containsSignedPreKey(for id: UInt32) -> Bool {
        return signedPreKeys[id] != nil
        
    }
    
    // Usuwa Signed PreKey dla podanego ID.
    func removeSignedPreKey(for id: UInt32) throws {
        if signedPreKeys.removeValue(forKey: id) != nil {
            print("Usunięto SignedPreKey dla ID: \(id)")
        } else {
            throw SignalError(.invalidId, "Nie znaleziono SignedPreKey dla ID: \(id)")
        }
    }
    
    
    // Zwraca listę wszystkich ID przechowywanych Signed PreKeys.
    func allIds() throws -> [UInt32] {
        return Array(signedPreKeys.keys)
    }
    
    func validateSignedPreKeys() throws -> SessionSignedPreKeyPublic {
        print("[INFO] Rozpoczynanie walidacji SignedPreKeys...")

        for id in signedPreKeys.keys {
            do {
                // Pobranie danych SignedPreKey
                let signedPreKeyData = try signedPreKey(for: id)

                // Sprawdzenie minimalnego rozmiaru danych
                guard signedPreKeyData.count >= 32 else {
                    print("[ERROR] SignedPreKey o ID \(id) ma nieprawidłowy rozmiar: \(signedPreKeyData.count) bajtów.")
                    continue
                }

                // Wstępna walidacja jako SessionSignedPreKey
                let signedPreKeyObject = try SessionSignedPreKey(from: signedPreKeyData)
                print("[INFO] SignedPreKey o ID \(id) przeszedł wstępną walidację jako SessionSignedPreKey.")

                // Pobranie publicznego klucza z SignedPreKeyPublic
                let signedPreKeyPublic = signedPreKeyObject.publicKey
                print("[INFO] PublicKey dla SignedPreKey o ID \(id): \(signedPreKeyPublic.key).")

                // Pobranie publicznego klucza z IdentityKeyStore
                let identityKey = try SignalKeyStore.shared.identityKeyStore.getIdentityKey()
                let publicIdentityKey = identityKey.publicKey
                print("[INFO] Pobranie PublicKey z IdentityKey zakończone sukcesem: \(publicIdentityKey).")

                // Tworzenie obiektu SessionSignedPreKeyPublic
                let signedPreKeyPublicObject = SessionSignedPreKeyPublic(
                    id: signedPreKeyPublic.id,
                    timestamp: signedPreKeyPublic.timestamp,
                    key: signedPreKeyPublic.key,
                    signature: signedPreKeyPublic.signature
                )
                print("[INFO] SignedPreKey o ID \(id) przeszedł walidację jako SessionSignedPreKeyPublic.")
                print("[DEBUG] SignedPreKeyPublic: \(signedPreKeyPublicObject)")
                return signedPreKeyPublicObject

            } catch {
                print("[ERROR] Błąd podczas walidacji SignedPreKey o ID \(id): \(error.localizedDescription)")
            }
        }

        throw SignalError(.invalidKey, "Brak poprawnych SignedPreKeys.")
    }

}

// Przechowywanie sesji
class InMemorySessionStore: SessionStore {
    
    typealias Address = SignalAddress
    // Przechowywanie sesji w formie słownika
    var sessions: [SignalAddress: Data] = [:]
    
    
    func loadSession(for address: SignalAddress) throws -> Data? {
        let sessionData = sessions[address]
            print("Ładowanie sesji dla adresu \(address): \(sessionData != nil ? "znaleziono" : "nie znaleziono")")
            return sessionData
    }
    
    func store(session: Data, for address: SignalAddress) throws {
        sessions[address] = session
        print("[DEBUG] Zapisano sesję dla adresu \(address). Rozmiar danych: \(session.count) bajtów.")
    }
    
    func containsSession(for address: SignalAddress) -> Bool {
        let exists = sessions[address] != nil
               print("[DEBUG] Sprawdzanie sesji dla adresu \(address): \(exists ? "istnieje" : "nie istnieje")")
               return exists
    }
    
    func deleteSession(for address: SignalAddress) throws {
        guard sessions.removeValue(forKey: address) != nil else {
                    throw SignalError(.storageError, "Nie znaleziono sesji dla adresu: \(address)")
                }
            }
    
    
    
}





