//
//  OutgoingMessage.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery
import SignalProtocol

class OutgoingMessage{
    
    
    class func send(chatID: String, text: String?, image: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, membersIDS:[String]){
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomID = chatID
        message.senderID = currentUser.id
        message.senderName = currentUser.userName
        message.senderInitials = String(currentUser.userName.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil{
            //send text message
            sendTextMessage(message: message, text: text!, membersIDS: membersIDS)
        }
        
        if image != nil{
            sendImageMessage(message: message, image: image!, membersIDS: membersIDS)
        }
        
        if video != nil{
           sendVideoMessage(message: message, video: video!, membersIDS: membersIDS)
        }
        
        if location != nil{
            sendLocationMessage(message: message, membersIDS: membersIDS)
        }
        if audio != nil{
            sendAudioMessage(message: message, audioName: audio!, audioDuration: audioDuration, membersIDS: membersIDS)
          //  print("send audio", audio, audioDuration)
        }
        
        FirebaseChatFeedback.shared.updateRecents(chatRoomId: chatID, lastMessage: message.message)
        
        
    }
    
    
    //saving to realm and firebase
    class func saveSendMessage(message: LocalMessage, memberIDS: [String]){
        RealmMessageManager.shared.saveInRealm(message)
        
        for memberID in memberIDS {
            FirebaseMessage.shared.addMessage(message, memberID: memberID)
        }
    }
    
    //saving to realm and firebase
    class func saveGroupSendMessage(message: LocalMessage, groups: Groups){
        RealmMessageManager.shared.saveInRealm(message)
        
        FirebaseMessage.shared.addGroupMessage(message, groups: groups)
    }
    
    
    //zpbacz jak to jest zrobione
    class func sendGroupMess(groups: Groups, text: String?, image: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?){
        let currentUser = User.currentUser!
        var groups = groups
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomID = groups.id
        message.senderID = currentUser.id
        message.senderName = currentUser.userName
        message.senderInitials = String(currentUser.userName.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil{
            //send text message
            sendTextMessageGroups(message: message, text: text!, membersIDS: groups.membersIDS, groups: groups)
        }
        
        if image != nil{
            sendImageMessage(message: message, image: image!, membersIDS: groups.membersIDS, groups: groups)
        }
        
        if video != nil{
           sendVideoMessage(message: message, video: video!, membersIDS: groups.membersIDS, groups: groups)
        }
        
        if location != nil{
            sendLocationMessage(message: message, membersIDS: groups.membersIDS, groups: groups)
        }
        if audio != nil{
            sendAudioMessage(message: message, audioName: audio!, audioDuration: audioDuration, membersIDS: groups.membersIDS, groups: groups)
          //  print("send audio", audio, audioDuration)
        }
    
        groups.lastMessageDate = Date()
        GroupFeedback.shared.addGroup(groups)
    }
}

func sendTextMessageGroups(message: LocalMessage, text: String, membersIDS: [String], groups: Groups? = nil){
     message.message = text
     message.typeOfMessage = kTEXT
    message.isEncrypted = false 
        OutgoingMessage.saveGroupSendMessage(message: message,groups: groups!)
    }


func sendTextMessage(message: LocalMessage, text: String, membersIDS: [String], groups: Groups? = nil) {
    let sessionManager = SessionManager.shared

    for recipientID in membersIDS where recipientID != User.currentId {
        do {
            // Przygotowanie odbiorcy i nadawcy
            let recipient = User(id: recipientID, userName: "", email: "", pushId: "", avatar: "", status: "")
            let sender = User.currentUser!
            
            // Szyfrowanie wiadomości
          //  let encryptedMessage = try sessionManager.encryptMessage(text, for: recipient, from: sender)
         //   let encryptedData = encryptedMessage.data
         //   message.message = encryptedData.base64EncodedString()
            message.message = text
            message.typeOfMessage = kTEXT
           // message.isEncrypted = true // Oznacz wiadomość jako zaszyfrowaną
            // Debugowanie danych zaszyfrowanych
                     //  print("[DEBUG] Zaszyfrowane dane wiadomości: \(encryptedData as NSData)")
                    //   print("[DEBUG] Wiadomość w Base64: \(message.message)")

          
                OutgoingMessage.saveSendMessage(message: message, memberIDS: membersIDS)
          
            print("Wiadomość zaszyfrowana i wysłana do użytkownika \(recipientID)")

        } catch {
            print("Błąd podczas szyfrowania wiadomości dla \(recipientID): \(error.localizedDescription)")
        }
    }
}




func sendImageMessage(message: LocalMessage, image: UIImage, membersIDS: [String], groups: Groups? =  nil){
    print("sending picture message")
    message.message = "Image Message"
    message.typeOfMessage = kIMAGE
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Images/" + "\(message.chatRoomID)/" + "_\(fileName)" + ".jpg"
    
    StorageFirebase.localSaveFile(fileDate: image.jpegData(compressionQuality: 0.5)! as NSData, fileName: fileName)
    
    StorageFirebase.imageUpload(image, directory: fileDirectory) { imageURL in
        if imageURL != nil {
            message.imageUrl = imageURL ?? ""
            
            if groups != nil {
                OutgoingMessage.saveGroupSendMessage(message: message, groups: groups!)
            }else {
                OutgoingMessage.saveSendMessage(message: message, memberIDS: membersIDS)
            }
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: Video, membersIDS: [String], groups: Groups? =  nil){
    message.message = "Video Message"
    message.typeOfMessage = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Images/" + "\(message.chatRoomID)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomID)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { processVideo, videoUrl in
        if let tempPath = videoUrl{
            let thumbnail = videoThumbNail(video: tempPath)
            StorageFirebase.localSaveFile(fileDate: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            StorageFirebase.imageUpload(thumbnail, directory: thumbnailDirectory) { imageLink in
                if imageLink != nil{
                    let videodata = NSData(contentsOfFile: tempPath.path)
                    StorageFirebase.localSaveFile(fileDate: videodata!, fileName: fileName + ".mov")
                    StorageFirebase.videoUpload(videodata!, directory: videoDirectory) { videoLink in
                        message.imageUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        if groups != nil {
                            OutgoingMessage.saveGroupSendMessage(message: message, groups: groups!)
                        }else {
                            OutgoingMessage.saveSendMessage(message: message, memberIDS: membersIDS)
                        }
                    }
                }
            }
        }
    }

}

func sendLocationMessage(message: LocalMessage, membersIDS: [String], groups: Groups? =  nil){
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.typeOfMessage = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    if groups != nil {
        OutgoingMessage.saveGroupSendMessage(message: message, groups: groups!)
    }else {
        OutgoingMessage.saveSendMessage(message: message, memberIDS: membersIDS)
    }
}

func sendAudioMessage(message: LocalMessage,audioName: String, audioDuration: Float, membersIDS: [String], groups: Groups? =  nil){
    message.message = "Audio message"
    message.typeOfMessage = kAUDIO
    let audioDirectory = "MediaMessages/Audio/" + "\(message.chatRoomID)/" + "_\(audioName)" + ".m4a"
    StorageFirebase.audioUpload(audioName, directory: audioName) { audioUrl in
        if audioUrl != nil{
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            
            OutgoingMessage.saveSendMessage(message: message, memberIDS: membersIDS)
        }
    }
    
   


    
 

}
