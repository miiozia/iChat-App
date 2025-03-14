//
//  ChatManagment.swift
//  iChat
//
//  Created by Marta Miozga on 21/10/2024.
//

import Foundation
import Firebase
import SignalProtocol

//MARK: - Start chat
func newChats(user1: User, user2: User) -> String{
    let chatId = chatsIDFrom(user1ID: user1.id, user2ID: user2.id)
    
    do {
        try SessionManager.shared.createSessionBetween(sender: user1, receiver: user2)
        } catch {
            print("Błąd podczas tworzenia sesji: \(error.localizedDescription)")
        }
    
    
    createRecentChatItems(chatId: chatId, users: [user1, user2])
    
    return chatId
}

func getReceiver(users: [User]) -> User{
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}




func restartChat(chatId: String, memberIDS: [String]){
    DatabaseUserFeedback.shared.downloadUsersFromFirebase(withIds: memberIDS) { users in
        if users.count > 0 {
            createRecentChatItems(chatId: chatId, users: users)
        }
    }
}

//MARK: - create recent chat

func createRecentChatItems(chatId: String, users: [User]){
    //does user have recent chat items ?
    
    var memberIDs = [users.first!.id, users.last!.id]
    FirebaseReference(.Recent).whereField(kCHATID, isEqualTo: chatId).getDocuments {
        
        (snapshot, error) in
      
        
        guard let snapshot = snapshot else{return}
        if !snapshot.isEmpty{
            memberIDs = removeRecentMemberChat(snapschot: snapshot, memberIDS: memberIDs)
    
        }
        
        for userId in memberIDs{
         
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiver(users: users)
            
            let receiverUser = userId == User.currentId ? getReceiver(users: users) : User.currentUser!
            
            let recentObject = ChatManage(id: UUID().uuidString,
                                          chatRoomID: chatId,
                                          senderID: senderUser.id,
                                          senderName: senderUser.userName,
                                          receiverID: receiverUser.id,
                                          receiverName: receiverUser.userName,
                                          date: Date(),
                                          membersIDS: [senderUser.id, receiverUser.id],
                                          lastMessage: "",
                                          unreadCounter: 0,
                                          avatar: receiverUser.avatar)
            
            FirebaseChatFeedback.shared.addRecentChat(recentObject)
        }
    }
}

func removeRecentMemberChat(snapschot: QuerySnapshot, memberIDS: [String]) -> [String]{
    
    var memberIDs = memberIDS
    
    for recentData in snapschot.documents{
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserId = currentRecent[kSENDERID]{
            if memberIDs.contains(currentUserId as! String){
                memberIDs.remove(at: memberIDs.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    
    return memberIDs
}

func chatsIDFrom (user1ID: String, user2ID: String ) -> String{
    var chatId = ""
    let value = user1ID.compare(user2ID).rawValue
    
    chatId = value < 0 ? (user1ID + user2ID) : (user2ID + user1ID)
    
    return chatId
}

extension SessionManager {
    func createSessionBetween(sender: User, receiver: User) throws {
        let senderAddress = SignalAddress(name: sender.id, deviceId: 1)
        let receiverAddress = SignalAddress(name: receiver.id, deviceId: 1)
        print("[INFO] Rozpoczynanie tworzenia sesji między \(sender.id) a \(receiver.id).")
        
        print("[INFO] Rozpoczynanie tworzenia sesji między \(sender.id) a \(receiver.id).")
                
                // Sprawdzenie, czy sesja już istnieje dla nadawcy
                if keyStore.sessionStore.containsSession(for: receiverAddress) {
                    print("[INFO] Sesja już istnieje dla \(receiver.id). Pominięto tworzenie nowej sesji.")
                    return
                }
                
                // Sprawdzenie, czy sesja już istnieje dla odbiorcy
                if keyStore.sessionStore.containsSession(for: senderAddress) {
                    print("[INFO] Sesja już istnieje dla \(sender.id). Pominięto tworzenie nowej sesji.")
                    return
                }
        
        // Przygotowanie PreKeyBundle dla nadawcy
        guard let senderPreKeyBundle = try? preparePreKeyBundle(
            for: sender.id,
            preKeyId: keyStore.preKeyStore.lastId,
            signedPreKeyId: keyStore.signedPreKeyStore.lastId
        ) else {
            print("[ERROR] Nie udało się przygotować PreKeyBundle dla \(sender.id).")
            throw SignalError(.invalidKey, "Nie udało się przygotować PreKeyBundle dla \(sender.id)")
        }
        
        // Log point: Informacja o wygenerowaniu senderPreKeyBundle
        print("[DEBUG] PreKeyBundle dla nadawcy (\(sender.id)) został wygenerowany: \(senderPreKeyBundle)")

        // Przygotowanie PreKeyBundle dla odbiorcy
        guard let receiverPreKeyBundle = try? preparePreKeyBundle(
            for: receiver.id,
            preKeyId: keyStore.preKeyStore.lastId,
            signedPreKeyId: keyStore.signedPreKeyStore.lastId
        ) else {
            print("[ERROR] Nie udało się przygotować PreKeyBundle dla \(receiver.id).")
            throw SignalError(.invalidKey, "Nie udało się przygotować PreKeyBundle dla \(receiver.id)")
        }
        print("[DEBUG] PreKeyBundle dla odbiorcy (\(receiver.id)) został wygenerowany: \(receiverPreKeyBundle)")

        // Tworzenie sesji
        try createSession(with: receiverPreKeyBundle, for: senderAddress)
        try createSession(with: senderPreKeyBundle, for: receiverAddress)
        
        print("[INFO] Sesje zostały pomyślnie utworzone między \(sender.id) a \(receiver.id).")
    }
}
