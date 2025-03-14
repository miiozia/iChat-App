//
//  SessionManager.swift
//  iChat
//
//  Created by Marta Miozga on 15/12/2024.
//

import Foundation
import SignalProtocol

class SessionManager {
    
    static let shared = SessionManager()
    
    let keyStore = SignalKeyStore.shared
    
    private var ciphers: [SignalAddress: SessionCipher<SignalKeyStore>] = [:]
    
    private init() {}
    
    
    
    // MARK: - Tworzenie sesji
    
    /// Tworzy nową sesję na podstawie PreKeyBundle odbiorcy.
    /// - Parameters:
    //   - bundle: PreKeyBundle odbiorcy.
    //   - address: Adres użytkownika (nazwa i ID urządzenia).
    /// - Throws: SignalError w przypadku błędu.
    
    
    func createSession(with bundle: SessionPreKeyBundle, for address: SignalAddress) throws {
            // Sprawdź, czy sesja już istnieje
            if keyStore.sessionStore.containsSession(for: address) {
                print("[INFO] Sesja już istnieje dla adresu: \(address.name)")
                return
            }

            do {
                // Tworzenie nowej sesji
                let sessionBuilder = SessionBuilder(remoteAddress: address, store: keyStore)
                
                try sessionBuilder.process(preKeyBundle: bundle)
                if let sessionData = try? keyStore.sessionStore.loadSession(for: address) {
                    print("Sesja zapisana dla adresu \(address.name). Rozmiar: \(sessionData.count) bajtów.")
                } else {
                    print("Nie udało się załadować zapisanej sesji dla adresu \(address.name).")
                }
            } catch {
                print("Błąd podczas tworzenia sesji dla adresu \(address.name): \(error.localizedDescription)")
                throw error
            }
        }

    func encryptMessage(_ plaintext: String, for receiver: User, from sender: User) throws -> CipherTextMessage {
        let receiverAddress = SignalAddress(name: receiver.id, deviceId: 1)

        // Upewnij się, że sesja istnieje
        if !keyStore.sessionStore.containsSession(for: receiverAddress) {
            try createSessionBetween(sender: sender, receiver: receiver)
        }

        if let session = try? keyStore.sessionStore.loadSession(for: receiverAddress) {
        }
       
        // Inicjalizacja szyfrowania
        let cipher = try initializeCipher(for: receiverAddress)
      

        guard let messageData = plaintext.data(using: .utf8) else {
            throw SignalError(.invalidMessage, "Nieprawidłowy format wiadomości")
        }

        do {
            let encryptedMessage = try cipher.encrypt(messageData)
            if encryptedMessage.type == .preKey {
                return encryptedMessage
            } else if encryptedMessage.type == .signal {
                return encryptedMessage
                
            } else {
                throw SignalError(.invalidType)
            }
        } catch {
            print("Błąd podczas szyfrowania wiadomości dla \(receiver.id): \(error.localizedDescription)")
            throw error
        }
    }


    
    // MARK: - Odszyfrowanie wiadomości
    func decryptMessage(from data: Data, sender: User) throws -> String {
        let senderAddress = SignalAddress(name: sender.id, deviceId: 1)

        // Sprawdź, czy sesja istnieje
        guard keyStore.sessionStore.containsSession(for: senderAddress) else {
            throw SignalError(.noSession, "Brak istniejącej sesji dla \(sender.id)")
        }

        let cipher = try initializeCipher(for: senderAddress)
        let decryptedData: Data

        // Rozpoznawanie typu wiadomości
        if data.first == 8 {
            let adjustedData = data.advanced(by: 1) // Pominięcie nagłówka Protobuf
            let preKeyMessage = try PreKeySignalMessage(from: adjustedData)
            decryptedData = try cipher.decrypt(preKeySignalMessage: preKeyMessage)

            // Usuwanie PreKey po wykorzystaniu
            if let preKeyId = preKeyMessage.preKeyId,
               (keyStore.preKeyStore as? InMemoryPreKeyStore)?.containsPreKey(for: preKeyId) == true {
                try (keyStore.preKeyStore as? InMemoryPreKeyStore)?.removePreKey(for: preKeyId)
            } else {
            }
        } else if let type = CipherTextType(from: data) {

            switch type {
            case .signal:
                let adjustedData = data.advanced(by: 1) // Pominięcie nagłówka Protobuf
                let signalMessage = try SignalMessage(from: adjustedData)
                decryptedData = try cipher.decrypt(signalMessage: signalMessage)
            default:
                throw SignalError(.invalidType)
            }
        } else {
            throw SignalError(.invalidProtoBuf)
        }

        // Konwersja odszyfrowanych danych na tekst
        guard let plaintext = String(data: decryptedData, encoding: .utf8) else {
            throw SignalError(.invalidMessage, "Nie można zdekodować danych na tekst.")
        }
        return plaintext
    }


    
    private func initializeCipher(for address: SignalAddress) throws -> SessionCipher<SignalKeyStore> {
         if let cipher = ciphers[address] {
             return cipher
         }
         let cipher = SessionCipher(store: keyStore, remoteAddress: address)
         ciphers[address] = cipher
         return cipher
     }


    
    /// Przygotowuje PreKeyBundle dla użytkownika.
    func preparePreKeyBundle(for userId: String, preKeyId: UInt32, signedPreKeyId: UInt32) throws -> SessionPreKeyBundle {
        do {
            // Walidacja IdentityKey
            let identityKey = try SignalKeyStore.shared.identityKeyStore.validateIdentityKey()

            // Walidacja PreKey
            guard let preKeyStore = SignalKeyStore.shared.preKeyStore as? InMemoryPreKeyStore else {
                throw SignalError(.storageError, "PreKeyStore nie jest typu InMemoryPreKeyStore")
            }
            let preKeyPublic = try preKeyStore.validatePreKeys()

            // Walidacja SignedPreKey
            guard let signedPreKeyStore = SignalKeyStore.shared.signedPreKeyStore as? InMemorySignedPreKeyStore else {
                throw SignalError(.storageError, "SignedPreKeyStore nie jest typu InMemorySignedPreKeyStore")
            }
            let signedPreKeyPublic = try signedPreKeyStore.validateSignedPreKeys()

            // Tworzenie PreKeyBundle
            let bundle = SessionPreKeyBundle(preKey: preKeyPublic, signedPreKey: signedPreKeyPublic, identityKey: identityKey)
            return bundle
        } catch {
            print("[ERROR] Nie udało się przygotować PreKeyBundle dla użytkownika \(userId): \(error.localizedDescription)")
            throw error
        }
    }

}
