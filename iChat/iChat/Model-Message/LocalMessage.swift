//
//  LocalMessage.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable{
    @objc dynamic var id = ""
    @objc dynamic var chatRoomID = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderID = ""
    @objc dynamic var senderName = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var typeOfMessage = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var audioDuration = 0.0
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var isEncrypted = false

   
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
