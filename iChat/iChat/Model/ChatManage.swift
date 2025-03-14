//
//  ChatManage.swift
//  iChat
//
//  Created by Marta Miozga on 13/10/2024.
//

import Foundation
import FirebaseFirestoreSwift


struct ChatManage: Codable {
    
    //MARK: - values
    var id = ""
    var chatRoomID = ""
    var senderID = ""
    var senderName = ""
    var receiverID = ""
    var receiverName = ""
  @ServerTimestamp  var date = Date()
    var membersIDS = [""]
    var lastMessage = ""
    var unreadCounter  = 0
    var avatar = ""
    
}
