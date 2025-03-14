//
//  Statuses.swift
//  iChat
//
//  Created by Marta Miozga on 06/10/2024.
//

import Foundation

enum Status: String {
    
    case Available = "Available"
    case Busy = "Busy"
    case BRB = "Be rigth back"
    case AtWork = "At work"
    case CantTalk = "Can not talk"
    case InaMeeting = "In a meeting"
    
    static var array: [Status] {
        var a: [Status] = []
        
        switch Status.Available{
        case .Available:
            a.append(.Available); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .BRB:
            a.append(.BRB); fallthrough
        case .AtWork:
            a.append(.AtWork); fallthrough
        case .CantTalk:
            a.append(.CantTalk); fallthrough
        case .InaMeeting:
            a.append(.InaMeeting);
        return a
            
        }
    }
    
}
