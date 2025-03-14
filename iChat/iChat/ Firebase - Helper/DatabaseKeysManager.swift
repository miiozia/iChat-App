import Foundation
import Firebase
import FirebaseFirestore
import RealmSwift
import SignalProtocol

class DatabaseKeysManager {
    static let shared = DatabaseKeysManager()
    
    private init() {}
    
    // MARK: -  Identity Key
    func saveIdentityKey(_ identityKey: Data, userId: String) {
        let keyDocument = [
            "identityKey": identityKey.base64EncodedString(),
            "timestamp": Date().timeIntervalSince1970
        ] as [String: Any]
        
        FirebaseReference(.Keys).document(userId).setData(keyDocument) { error in
            if let error = error {
                print("[ERROR] Nie udało się zapisać IdentityKey w Firebase: \(error.localizedDescription)")
            } else {
                print("[INFO] IdentityKey został zapisany w Firebase dla użytkownika \(userId)")
            }
        }
    }
    
    // MARK: - PreKeys
    func savePreKeys(_ preKeys: [UInt32: Data], userId: String) {
        for (id, keyData) in preKeys {
            let preKeyDocument = [
                "preKeyId": id,
                "keyData": keyData.base64EncodedString(),
                "timestamp": Date().timeIntervalSince1970
            ] as [String: Any]
            
            FirebaseReference(.Keys).document(userId).collection("preKeys").document("\(id)").setData(preKeyDocument) { error in
                if let error = error {
                    print("[ERROR] Nie udało się zapisać PreKey o ID \(id) w Firebase: \(error.localizedDescription)")
                } else {
                    print("[INFO] PreKey o ID \(id) został zapisany w Firebase dla użytkownika \(userId)")
                }
            }
        }
    }
    
    // MARK: - SignedPreKey
    
    func saveSignedPreKey(_ signedPreKey: Data, keyId: UInt32, userId: String) {
        let signedPreKeyDocument = [
            "signedPreKeyId": keyId,
            "keyData": signedPreKey.base64EncodedString(),
            "timestamp": Date().timeIntervalSince1970
        ] as [String: Any]
        
        FirebaseReference(.Keys).document(userId).collection("signedPreKeys").document("\(keyId)").setData(signedPreKeyDocument) { error in
            if let error = error {
                print("[ERROR] Nie udało się zapisać SignedPreKey o ID \(keyId) w Firebase: \(error.localizedDescription)")
            } else {
                print("[INFO] SignedPreKey o ID \(keyId) został zapisany w Firebase dla użytkownika \(userId)")
            }
        }
    }
    
    
    // MARK: -  Sessions
    
    func saveSession(_ session: Data, address: SignalAddress, userId: String) {
        let sessionDocument = [
            "address": address.description,
            "sessionData": session.base64EncodedString(),
            "timestamp": Date().timeIntervalSince1970
        ] as [String: Any]
        
        FirebaseReference(.Keys).document(userId).collection("sessions").document(address.description).setData(sessionDocument) { error in
            if let error = error {
                print("[ERROR] Nie udało się zapisać sesji dla adresu \(address) w Firebase: \(error.localizedDescription)")
            } else {
                print("[INFO] Sesja dla adresu \(address) została zapisana w Firebase dla użytkownika \(userId)")
            }
        }
    }
    
    // MARK: - Synchronize All Keys
    
    func synchronizeKeys(store: SignalKeyStore, userId: String) {
        do {
            // Zapisz Identity Key
            let identityKeyData = try store.identityKeyStore.getIdentityKeyData()
            saveIdentityKey(identityKeyData, userId: userId)
            
            // Zapisz PreKeys
            if let preKeyStore = store.preKeyStore as? InMemoryPreKeyStore {
                savePreKeys(preKeyStore.preKeys, userId: userId)
            }
            
            // Zapisz SignedPreKey
            if let signedPreKeyStore = store.signedPreKeyStore as? InMemorySignedPreKeyStore {
                let signedPreKeyId = signedPreKeyStore.lastId
                if let signedPreKeyData = try? signedPreKeyStore.signedPreKey(for: signedPreKeyId) {
                    saveSignedPreKey(signedPreKeyData, keyId: signedPreKeyId, userId: userId)
                }
            }
            
            // Zapisz sesje
            let sessionStore = store.sessionStore
            if let inMemorySessionStore = sessionStore as? InMemorySessionStore {
                for (address, sessionData) in inMemorySessionStore.sessions {
                    saveSession(sessionData, address: address, userId: userId)
                }
            }
            
            print("[INFO] Synchronizacja kluczy z Firebase zakończona dla użytkownika \(userId)")
            
        } catch {
            print("[ERROR] Błąd podczas synchronizacji kluczy z Firebase: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Load
    
    func loadIdentityKey(userId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        FirebaseReference(.Keys).document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let keyString = data["identityKey"] as? String,
                  let keyData = Data(base64Encoded: keyString) else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(SignalError(.storageError, "IdentityKey nie istnieje dla użytkownika \(userId)")))
                }
                return
            }
            
            print("[INFO] Pobrano IdentityKey z Firebase dla użytkownika \(userId)")
            completion(.success(keyData))
        }
    }
    
    func loadPreKeys(userId: String, completion: @escaping (Result<[UInt32: Data], Error>) -> Void) {
        FirebaseReference(.Keys).document(userId).collection("preKeys").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(SignalError(.storageError, "Brak PreKeys dla użytkownika \(userId)")))
                }
                return
            }
            
            var preKeys: [UInt32: Data] = [:]
            for document in documents {
                if let id = UInt32(document.documentID),
                   let keyString = document.data()["keyData"] as? String,
                   let keyData = Data(base64Encoded: keyString) {
                    preKeys[id] = keyData
                }
            }
            
            print("[INFO] Pobrano \(preKeys.count) PreKeys z Firebase dla użytkownika \(userId)")
            completion(.success(preKeys))
        }
    }
    
    func loadSignedPreKeys(userId: String, completion: @escaping (Result<[UInt32: Data], Error>) -> Void) {
        FirebaseReference(.Keys).document(userId).collection("signedPreKeys").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(SignalError(.storageError, "Brak SignedPreKeys dla użytkownika \(userId)")))
                }
                return
            }
            
            var signedPreKeys: [UInt32: Data] = [:]
            for document in documents {
                if let id = UInt32(document.documentID),
                   let keyString = document.data()["keyData"] as? String,
                   let keyData = Data(base64Encoded: keyString) {
                    signedPreKeys[id] = keyData
                }
            }
            completion(.success(signedPreKeys))
        }
    }
    
    
    /// Synchronizuje klucze między lokalnym magazynem a Firebase.
    /// Jeśli klucze nie istnieją w lokalnym magazynie, pobiera je z Firebase i zapisuje w magazynie.
    func syncKeysWithStoreAndFirebase(for store: SignalKeyStore, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        let group = DispatchGroup()
        var syncError: Error?
        
        // Sprawdzenie IdentityKey
        if (try? store.identityKeyStore.getIdentityKeyData()) == nil {
            group.enter()
            self.loadIdentityKey(userId: userId) { result in
                switch result {
                case .success(let identityKeyData):
                    do {
                        // Utwórz KeyPair na podstawie pobranych danych
                        let keyPair = try KeyPair(from: identityKeyData)

                        // Przypisz KeyPair i dane do istniejącego magazynu identityKeyStore
                        store.identityKeyStore.identityKeyPair = keyPair
                        store.identityKeyStore.serializedIdentityKeyData = identityKeyData
                    } catch {
                        print("[ERROR] Błąd podczas inicjalizacji KeyPair: \(error.localizedDescription)")
                        syncError = error
                    }
                case .failure(let error):
                    syncError = error
                }
                group.leave()
            }
        } else {
            print("[INFO] IdentityKey istnieje w magazynie.")
        }

        
        // Sprawdzenie PreKeys
        if let preKeyStore = store.preKeyStore as? InMemoryPreKeyStore, preKeyStore.preKeys.isEmpty {
            group.enter()
            self.loadPreKeys(userId: userId) { result in
                switch result {
                case .success(let preKeys):
                    preKeyStore.preKeys = preKeys
                    print("[INFO] PreKeys załadowane z Firebase i zapisane w magazynie.")
                case .failure(let error):
                    print("[ERROR] Nie udało się załadować PreKeys z Firebase: \(error.localizedDescription)")
                    syncError = error
                }
                group.leave()
            }
        } else {
            print("[INFO] PreKeys istnieją w magazynie.")
        }
        
        /// Synchronizuje klucze między lokalnym magazynem a Firebase.
        func syncKeysWithStoreAndFirebase(for store: SignalKeyStore, userId: String, completion: @escaping (Bool, Error?) -> Void) {
            let group = DispatchGroup()
            var syncError: Error?
            
            // Sprawdzenie IdentityKey
            if (try? store.identityKeyStore.getIdentityKeyData()) == nil {
                print("[INFO] IdentityKey nie istnieje w magazynie. Próba pobrania z Firebase...")
                group.enter()
                self.loadIdentityKey(userId: userId) { result in
                    switch result {
                    case .success(let identityKeyData):
                        do {
                            // Zainicjalizuj klucz w istniejącym magazynie IdentityKeyStore
                            try store.identityKeyStore.store(identity: identityKeyData, for: SignalAddress(name: userId, deviceId: 1))
                            print("[INFO] IdentityKey załadowany z Firebase i zapisany w magazynie.")
                        } catch {
                            print("[ERROR] Błąd podczas zapisywania IdentityKey w magazynie: \(error.localizedDescription)")
                            syncError = error
                        }
                    case .failure(let error):
                        print("[ERROR] Nie udało się załadować IdentityKey z Firebase: \(error.localizedDescription)")
                        syncError = error
                    }
                    group.leave()
                }
            } else {
                print("[INFO] IdentityKey istnieje w magazynie.")
            }
            
            // Sprawdzenie PreKeys
            if let preKeyStore = store.preKeyStore as? InMemoryPreKeyStore, preKeyStore.preKeys.isEmpty {
                print("[INFO] PreKeys nie istnieją w magazynie. Próba pobrania z Firebase...")
                group.enter()
                self.loadPreKeys(userId: userId) { result in
                    switch result {
                    case .success(let preKeys):
                        preKeyStore.preKeys = preKeys
                        print("[INFO] PreKeys załadowane z Firebase i zapisane w magazynie.")
                    case .failure(let error):
                        print("[ERROR] Nie udało się załadować PreKeys z Firebase: \(error.localizedDescription)")
                        syncError = error
                    }
                    group.leave()
                }
            } else {
                print("[INFO] PreKeys istnieją w magazynie.")
            }
            
            // Sprawdzenie SignedPreKeys
            if let signedPreKeyStore = store.signedPreKeyStore as? InMemorySignedPreKeyStore {
                do {
                    if try signedPreKeyStore.allIds().isEmpty {
                        print("[INFO] SignedPreKeys nie istnieją w magazynie. Próba pobrania z Firebase...")
                        group.enter()
                        self.loadSignedPreKeys(userId: userId) { result in
                            switch result {
                            case .success(let signedPreKeys):
                                do {
                                    for (id, data) in signedPreKeys {
                                        try signedPreKeyStore.store(signedPreKey: data, for: id)
                                    }
                                    print("[INFO] SignedPreKeys załadowane z Firebase i zapisane w magazynie.")
                                } catch {
                                    print("[ERROR] Błąd podczas zapisywania SignedPreKeys w magazynie: \(error.localizedDescription)")
                                    syncError = error
                                }
                            case .failure(let error):
                                print("[ERROR] Nie udało się załadować SignedPreKeys z Firebase: \(error.localizedDescription)")
                                syncError = error
                            }
                            group.leave()
                        }
                    } else {
                        print("[INFO] SignedPreKeys istnieją w magazynie.")
                    }
                } catch {
                    print("[ERROR] Błąd podczas sprawdzania SignedPreKeys w magazynie: \(error.localizedDescription)")
                    syncError = error
                }
            }
            
            // Wywołanie completion po zakończeniu wszystkich operacji
            group.notify(queue: .main) {
                if let error = syncError {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
        
        
        
    }
}
