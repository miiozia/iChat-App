//
//  IncomingMessage.swift
//  iChat
//
//  Created by Marta Miozga on 01/11/2024.
//

import Foundation
import MessageKit
import CoreLocation
import SignalProtocol

class IncomingMessage{
    
    //MARK: - vars
    var messageViewController: MessagesViewController
    
    init(_collectionView: MessagesViewController){
        messageViewController = _collectionView
    }
    
    //MARK: - create message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage?{
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.typeOfMessage == kIMAGE{
            let imageItem = ImageMessage(path: localMessage.imageUrl)
            mkMessage.imageItem = imageItem
            mkMessage.kind = MessageKind.photo(imageItem)
            StorageFirebase.downloadImage(imageUrl: localMessage.imageUrl) { image in
                mkMessage.imageItem?.image = image
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        if localMessage.typeOfMessage == kVIDEO{
            StorageFirebase.downloadImage(imageUrl: localMessage.imageUrl) { thumbnail in
                StorageFirebase.downloadVideo(videoLink: localMessage.videoUrl) { readyToPlay, fileName in
                    let videoURL = URL(fileURLWithPath: filesFromDocDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videoURL)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                mkMessage.videoItem?.image = thumbnail
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.typeOfMessage == kLOCATION{
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.typeOfMessage == kAUDIO{
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            StorageFirebase.downloadAudio(audioLink: localMessage.audioUrl) { fileName in
                let audioURL = URL(fileURLWithPath: filesFromDocDirectory(fileName: fileName))
                mkMessage.audioItem?.url = audioURL
                
            }
            self.messageViewController.messagesCollectionView.reloadData()
        }
        
        /*   if localMessage.typeOfMessage == kTEXT {
                   if localMessage.isEncrypted {
                       // Wiadomość zaszyfrowana
                       if let encryptedData = Data(base64Encoded: localMessage.message) {
                           
                           do {
                            
                               let sender = User(id: localMessage.senderID, userName: "", email: "", pushId: "", avatar: "", status: "")
                               // Odszyfrowanie wiadomości
                               let decryptedText = try SessionManager.shared.decryptMessage(from: encryptedData, sender: sender)
                                           
                                       mkMessage.kind = MessageKind.text(decryptedText)
                           } catch {
                             
                               mkMessage.kind = MessageKind.text(localMessage.message)
                           }
                       } else {
                           mkMessage.kind = MessageKind.text(localMessage.message)
                       }
                   } else {
                       // Wiadomość niezaszyfrowana
                       mkMessage.kind = MessageKind.text(localMessage.message)
                   }
               }*/
        
        return mkMessage
    }
    
}
