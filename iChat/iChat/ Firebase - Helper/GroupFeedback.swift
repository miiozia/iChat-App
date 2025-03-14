//
//  GroupFeedback.swift
//  iChat
//
//  Created by Marta Miozga on 24/11/2024.
//

import Foundation
import Firebase

class GroupFeedback {
    static let shared = GroupFeedback()
    
    var groupFeedback: ListenerRegistration!
    
    private init(){}
  
    func downloadUsersGroupFromFirebase(completion: @escaping (_ allGroups: [Groups]) -> Void){
        groupFeedback = FirebaseReference(.Groups).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ querySnapshot, error in
            guard let document = querySnapshot?.documents else {
                print("no documnets for user channel")
                
                return
            }
            
            var allGroups = document.compactMap { (queryDocumentSnapshot) -> Groups? in
                return try? queryDocumentSnapshot.data(as: Groups.self)
                
            }
            allGroups.sort(by: { $0.membersIDS.count > $1.membersIDS.count})
            completion(allGroups)
        })
    }
    
    func downloadSubscribedGroups(completion: @escaping (_ allGroups: [Groups]) -> Void){
        groupFeedback = FirebaseReference(.Groups).whereField(kMEMBERSIDS, arrayContains: User.currentId).addSnapshotListener({ querySnapshot, error in
            guard let document = querySnapshot?.documents else {
                print("no documnets for subscribed groups")
                
                return
            }
            
            var allGroups = document.compactMap { (queryDocumentSnapshot) -> Groups? in
                return try? queryDocumentSnapshot.data(as: Groups.self)
                
            }
            allGroups.sort(by: { $0.membersIDS.count > $1.membersIDS.count})
            completion(allGroups)
        })
    }
    
    func downloadAllGroups(completion: @escaping (_ allGroups: [Groups]) -> Void){
        FirebaseReference(.Groups).getDocuments {
           ( querySnapshot, error ) in
            
            guard let documents = querySnapshot?.documents else{
                print("no documents for all groups")
                return
            }
            
            var allGroups = documents.compactMap { queryDocumentSnapshot -> Groups?  in
                return try? queryDocumentSnapshot.data(as: Groups.self)
            }
            
            allGroups = self.removeSubscribedGroups(allGroups)
            allGroups.sort(by: { $0.membersIDS.count > $1.membersIDS.count})
            completion(allGroups)
            
        }
    }
    
    //MARK: - add update and delete
    
    func addGroup(_ groups: Groups){
        do {
            try FirebaseReference(.Groups).document(groups.id).setData(from: groups)
        }
        catch {
            print("Error saving groups")
        }
    }
    
    func deleteGroup (_ group: Groups){
        FirebaseReference(.Groups).document(group.id).delete()
    }
    
    func removeSubscribedGroups(_ allGroups: [Groups]) -> [Groups] {
        var newGroups: [Groups] = []
        
        for groups in allGroups {
            if !groups.membersIDS.contains(User.currentId) {
                newGroups.append(groups)
            }
        }
        return newGroups
    }
    
    func removeGroupListener(){
        self.groupFeedback.remove()
    }
}
