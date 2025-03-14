//
//  MessageDataSource.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
         mkMessages.count
    }
    
    //MARK: - labels in chat view - MessageKit
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0{
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayMessagesCount)
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 12)
            let colour = showLoadMore ? UIColor.lightGray : UIColor.lightGray
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor : colour])
        }
        return nil
    }
    
    //MARK: - chat view  bottom label
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message){
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.showTime() : ""
          
           
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor .darkGray])
        }
        return nil
    }
    //MARK: - chat view bottom labels
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let colour = UIColor.darkGray
            return NSAttributedString(string: message.sentDate.showTime(), attributes: [.font : font, .foregroundColor : colour])
        }
        return nil
    }
}

extension GroupChatViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
         mkMessages.count
    }
    
    //MARK: - labels in chat view - MessageKit
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0{
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayMessagesCount)
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 12)
            let colour = showLoadMore ? UIColor.lightGray : UIColor.lightGray
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor : colour])
        }
        return nil
    }
    
    //MARK: - chat view bottom labels
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let colour = UIColor.darkGray
            return NSAttributedString(string: message.sentDate.showTime(), attributes: [.font : font, .foregroundColor : colour])
        }
        return nil
    }
}

