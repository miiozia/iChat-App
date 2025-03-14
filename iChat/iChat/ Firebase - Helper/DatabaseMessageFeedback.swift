//
//  DatabaseMessageFeedback.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessage{
    static let shared = FirebaseMessage()
    
    //MARK: - vars
    var newChatFromFirebase: ListenerRegistration!
    var updateChatFromFirebase: ListenerRegistration!
    
    private init(){}
    
    //MARK: - functions
    func newChatFirebase(_ documentId: String, collectionId: String, lastMessageDate: Date){
        newChatFromFirebase = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else{ return }
            for change in snapshot.documentChanges{
                if change.type == .added{
                    let result = Result{
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject{
                            if message.senderID != User.currentId {
                                RealmMessageManager.shared.saveInRealm(message)
                            }
                        }else {
                            print("Documnet does not exist")
                        }
                    case .failure(let error):
                        print("Error where decoding local message: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func readStatusChange(_ documentId: String, collectionId: String, completion: @escaping(_ updatedMessage: LocalMessage) -> Void){
        
        updateChatFromFirebase = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ querySnapshot, error in
            guard let snapshot = querySnapshot else{return}
            for change in snapshot.documentChanges{
                if change.type == .modified{
                    let result = Result{
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject):
                        
                        if let message = messageObject{
                            completion(message)
                        }else{
                            print("Document has not exist in chat")
                        }
                    case .failure(let error):
                        print("Error decoding local message: ", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String){
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else{
                print("No documents for old chats")
                return
            }
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            for message in oldMessages {
                RealmMessageManager.shared.saveInRealm(message)
            }
        }
    }
    
    //MARK: - Add, Update, Delete
    
    func addMessage(_ message: LocalMessage, memberID: String){
        do{
            let _ = try FirebaseReference(.Messages).document(memberID).collection(message.chatRoomID).document(message.id).setData(from: message)
            print("Dodawanie wiadomości do Firebase dla użytkownika \(memberID): \(message)")

        }catch{
            print("error saving message", error.localizedDescription)
        }
    }
    
    func addGroupMessage(_ message: LocalMessage, groups: Groups){
        do{
            let _ = try FirebaseReference(.Messages).document(groups.id).collection(groups.id).document(message.id).setData(from: message)

        }catch{
            print("error saving message", error.localizedDescription)
        }
    }
    
    
    
    //MARK: - status of message
    func updateMessageStatus(_ message: LocalMessage, memberIDS: [String]){
        let values = [kSTATUS : KREAD, kREADDATE : Date()] as! [String : Any]
        
        for userID in memberIDS {
            FirebaseReference(.Messages).document(userID).collection(message.chatRoomID).document(message.id).updateData(values)
        }
    }
    
    
    func removeListener(){
        self.newChatFromFirebase.remove()
        
        if self.updateChatFromFirebase != nil{
            self.updateChatFromFirebase.remove()}
        
    }
    
    
    
    
    
}
