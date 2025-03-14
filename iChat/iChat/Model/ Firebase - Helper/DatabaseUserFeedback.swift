//
//  DatabaseUserFeedback.swift
//  iChat
//
//  Created by Marta Miozga on 02/10/2024.
//


//FirebaseUserListener - usunac
import Foundation
import Firebase

    ////FirebaseUserListener - usunac
class DatabaseUserFeedback {
    static let shared = DatabaseUserFeedback()
    
    private init () {}
    
    //MARK: Login
    //loginUserByEmail
    func loginUserByEmail( email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (AuthDataResult, error)in
            if error == nil && AuthDataResult!.user.isEmailVerified{
                
                DatabaseUserFeedback.shared.downloadUserFromFirebase(userId: AuthDataResult!.user.uid, email: email)
                completion(error, true)
            }else {
                print("Email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: Registration
    // registerUserWith - usunac
    func registerUserBy(email: String, password: String, completion: @escaping(_ error: Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) {
            (AuthDataResult, error) in
            
            completion(error)
            
            if error == nil {
                //veryfication email sending
                AuthDataResult!.user.sendEmailVerification{ (error) in print("Authentication email send with error: ", error?.localizedDescription)
                    
                }
                
                //creating user account and save it
                
                if AuthDataResult?.user != nil {
                    let user = User(id: AuthDataResult!.user.uid , userName: email, email: email, pushId: "" , avatar: "", status: "Hi, I'm using iChat")
                    
                    savingUserData(user)
                    self.savingUserInFirestore(user)
                }
            }
        }
        
    }
    
    //MARK: resend email link method
    
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
     
    func logOutUser(completion: @escaping (_ error: Error?)-> Void){
        do {
          try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
            
        }
        catch let error as NSError{
            completion(error)
        }
    }
                                        
    //MARK: save user in firestore
    func savingUserInFirestore(_ user: User){
        do{
            try FirebaseReference(.User).document(user.id).setData(from: user)
                
        }catch{
            print(error.localizedDescription, "Adding user")
        }
    }
    
    //MARK: download user data from Firebase
    
    
    func downloadUserFromFirebase(userId: String, email: String? = nil){
        FirebaseReference(.User).document(userId).getDocument { (QuerySnapshot, error) in
            guard let document = QuerySnapshot else {
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
}

