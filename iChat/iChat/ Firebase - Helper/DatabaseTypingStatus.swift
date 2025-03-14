//
//  DatabaseTypingStatus.swift
//  iChat
//
//  Created by Marta Miozga on 03/11/2024.
//

import Foundation
import Firebase

class FirebaseTypingStatus{
    static let shared = FirebaseTypingStatus()
    
    var typingListener: ListenerRegistration!
    
    private init(){}
    
    func createTypingStatus(chatRoomID: String, completion: @escaping (_ isTyping: Bool) -> Void){
        typingListener = FirebaseReference(.Typing).document(chatRoomID).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists{
                for data in snapshot.data()!{
                    if data.key != User.currentId{
                        completion(data.value as! Bool)
                    }
                }
            }else {
                FirebaseReference(.Typing).document(chatRoomID).setData([User.currentId : false ])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomID: String){
        
        FirebaseReference(.Typing).document(chatRoomID).updateData([User.currentId : typing])
    }
    
    func deleteTypingListener(){
        self.typingListener.remove()
    }
}
