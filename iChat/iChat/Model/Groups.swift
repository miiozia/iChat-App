//
//  Groups.swift
//  iChat
//
//  Created by Marta Miozga on 24/11/2024.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Groups: Codable {
    
    var id = ""
    var name = ""
    var about = ""
    var adminID = ""
    var membersIDS = [""]
    var avatar  = ""
    @ServerTimestamp  var createdDate = Date()
    @ServerTimestamp  var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        case  id
        case name
        case about
        case adminID
        case membersIDS
        case avatar
        case createdDate
        case lastMessageDate = "date"
    }
    
}
