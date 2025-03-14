//
//  MessageKitHelper.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable{
    var senderId: String
    var displayName: String
}

enum MessageDefaults{
    //buble
    static let bubleColorOutgoing = UIColor(red: 119/255, green: 136/255, blue: 153/255, alpha: 1.0)
    static let bubleColorIngoing =  UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1.0)
    
}
