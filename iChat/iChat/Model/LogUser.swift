//
//  LogUser.swift
//  iChat
//
//  Created by Marta Miozga on 02/10/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id = ""
    var userName: String
    var email: String
    var pushId = ""
    var avatar = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER)
            {
              let decoder = JSONDecoder()
                do {
                    let UserObject = try decoder.decode(User.self, from: dictionary)
                    return UserObject
                }catch{
                    print("Error decoding user form user defaults", error.localizedDescription)
                }
            }
        }
        return nil
    }
    static func == (lhs: User, rhs:User) -> Bool{
        lhs.id == rhs.id
    }
}

func savingUserData(_ user: User){
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    }catch{
        print("error with saving user data", error.localizedDescription)
    }
}

func createTestUsers(){
    print("Creating Test users ")
    
    let names = ["Marta Kowalska", "Adam Kowalski", "Ewa Kowalska", "Iwona Kowalska", "Michal Kowalski", "Andrzej Kowalski"]
    
    var imageIndex = 1
    var userIdex = 1
    
    for i in 0..<5{
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        
        StorageFirebase.imageUpload(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { avatar in
            
            let user = User(id: id, userName: names[i], email: "user\(userIdex)@mail.com",avatar: avatar ?? "", status: "Hi, I am new ")
            
            userIdex += 1
            DatabaseUserFeedback.shared.savingUserInFirestore(user)
        }
        imageIndex += 1
        
        if imageIndex == 5{
            imageIndex = 1
        }
        
    }
}

