//
//  DatabaseChatFeedback.swift
//  iChat
//
//  Created by Marta Miozga on 21/10/2024.
//

import Foundation
import Firebase

class FirebaseChatFeedback{
    static let shared = FirebaseChatFeedback()
    
    private init(){}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [ChatManage]) ->Void) {
       // print("User.currentId: \(User.currentId)")
    
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo:   User.currentId).addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                print("Błąd podczas pobierania czatów: \(error.localizedDescription)")
                return
            }
               
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            print("znaleziono dokumenty:\(documents.count)")
            
            var recentChats: [ChatManage] = []
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> ChatManage? in
                return try? queryDocumentSnapshot.data(as: ChatManage.self)
            }
            
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
            
        }
    }
      
    func resetUnreadMessage(chatId: String){
        FirebaseReference(.Recent).whereField(kCHATID, isEqualTo: chatId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("No information about this")
                return
            }
            
            let allRecents = documents.compactMap {(queryDocumentSnapshot) -> ChatManage? in
                return  try? queryDocumentSnapshot.data(as:ChatManage.self)
            }
            if allRecents.count > 0 {
                self.clearUnreadMess(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> ChatManage? in
                return try? queryDocumentSnapshot.data(as: ChatManage.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: ChatManage, lastMessage: String) {
        
        var tempRecent = recent
        
        if tempRecent.senderID != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.addRecentChat(tempRecent)
    }
        
        func addRecentChat(_ recent: ChatManage){
            
            do {
                try  FirebaseReference(.Recent).document(recent.id).setData(from: recent)
            }catch {
                print("Error saving recent chat", error.localizedDescription)
            }
        }
        
        
        func clearUnreadMess(recent: ChatManage){
            var recentChat = recent
            recentChat.unreadCounter = 0
            self.addRecentChat(recentChat)
        }
        
        
        func deleteChat(_ recent: ChatManage){
            FirebaseReference(.Recent).document(recent.id).delete()
        }
        
    }

