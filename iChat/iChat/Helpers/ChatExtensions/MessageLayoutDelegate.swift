//
//  MessageLayoutDelegate.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesLayoutDelegate {
    //MARK: -  chat view top labels
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            if ((indexPath.section == 0) && (allLocalMessages.count > displayMessagesCount)){
                return 40
            }
            return 18
        }
        return 0
    }
    
    //read status
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    //MARK: -  chat view botton labels
    //if is last message return 10 otherwise 0
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}

extension GroupChatViewController: MessagesLayoutDelegate {
    //MARK: -  chat view top labels
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            if ((indexPath.section == 0) && (allLocalMessages.count > displayMessagesCount)){
                return 40
            }
            return 18
        }
        return 0
    }
    
    //read status //mozna zakomentowac 
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    //MARK: -  chat view botton labels
    //if is last message return 10 otherwise 0
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 10
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}
