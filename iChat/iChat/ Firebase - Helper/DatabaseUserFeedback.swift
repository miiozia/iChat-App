//
//  DatabaseUserFeedback.swift
//  iChat
//
//  Created by Marta Miozga on 02/10/2024.
//


import Foundation
import Firebase
import SignalProtocol

class DatabaseUserFeedback {
    static let shared = DatabaseUserFeedback()
    private init () {}
    
    //MARK: - Login
    
    func loginUserByEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                
                if error == nil &&  authDataResult!.user.isEmailVerified {
                    // Pobierz dane użytkownika z Firebase
                    DatabaseUserFeedback.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                    // Sprawdź i ewentualnie generuj klucze szyfrowania
                    // Inicjalizacja kluczy szyfrowania
                                do {
                                    try KeyManager.shared.initializeKeys(for: SignalKeyStore.shared, preKeyCount: 10)

                                } catch {
                                    print("Błąd podczas inicjalizacji kluczy szyfrowania: \(error.localizedDescription)")
                                }
                } else {
                    print("Email nie jest zweryfikowany.")
                    completion(error, false)
                }
                
            }
        }


    
    
    //MARK: - Registration
    
    func registerUserBy(email: String, password: String, completion: @escaping(_ error: Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) {
            (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                //veryfication email sending
                authDataResult!.user.sendEmailVerification{ (error) in print("Authentication email send with error: ", error?.localizedDescription)
                    
                }
                
                //creating user account and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid , userName: email, email: email, pushId: "" , avatar: "", status: "Hi, I'm using iChat")
                    
                    savingUserData(user)
                    self.savingUserInFirestore(user)
                    
                    
                    
                }
            }
        }
    }



    
    //MARK: - resend email link method
    
    func resendVerifyEmail(email: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().currentUser?.reload(completion: { (eror) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (eror) in
                completion(eror)
            })
        })
    }
    
    func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func logOutUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            print("Wylogowanie z firebase zakończone sukcesem.")
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            
            completion(error)
        }
    }


    
    //MARK: -  save user in firestore
    func savingUserInFirestore(_ user: User){
        do{
            try FirebaseReference(.User).document(user.id).setData(from: user)
            
        }catch{
            print(error.localizedDescription, "Adding user")
        }
    }
    
    //MARK: - download user data from Firebase
    
    func downloadUserFromFirebase(userId: String, email: String? = nil){
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject{
                    savingUserData(user)
                }else {
                    print ("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping(_ allUsers: [User]) -> Void){
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 50).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else{
                print("no documents in all users")
                return
            }
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            for user in allUsers{
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void){
        var count = 0
        var arrayofUsers: [User] = []
        
        for userId in withIds{
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error)  in
                guard let document = querySnapshot  else{
                    print("no documents in all users")
                    return
                }
                let user = try? document.data(as: User.self)
                
                arrayofUsers.append(user!)
                count += 1
                
                if count == withIds.count{
                    completion(arrayofUsers)
                }
            }
        }
    }
    
    //MARK: - Update
    
    func updateUserInFirebase(_ user: User){
        do{
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        }catch{
            print(error.localizedDescription,"updating users...")
        }
    }
    
}



