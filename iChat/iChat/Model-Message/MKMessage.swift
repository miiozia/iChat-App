//
//  MKMessage.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType{

    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType{return mkSender}
    var senderInitials: String
    var imageItem: ImageMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    var status: String
    var readDate: Date
    var isEncrypted: Bool = false
 
    init(message: LocalMessage){
        
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderID, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.isEncrypted = message.isEncrypted
        
        switch message.typeOfMessage {
        
        case kTEXT:
            self.kind = MessageKind.text(message.message)
            
        case kIMAGE:
            let imageItem = ImageMessage(path: message.imageUrl)
            self.kind = MessageKind.photo(imageItem)
            self.imageItem = imageItem
            
        case kVIDEO:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
            
        case kAUDIO:
            let audioItem = AudioMessage(duration: 2.0)
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
            
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
    }
    
}
