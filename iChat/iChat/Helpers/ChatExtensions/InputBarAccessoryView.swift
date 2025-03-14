//
//  InputBarAccessoryView.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {
    //funkcja wywyloywana jak ktos napisze cokolwiek na chacie
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != ""{
            typingIndicatorUpdate()
        }
        microfonButtonStatus(show: text == "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components{
            if let text = component as? String{
               sendMessage(text: text, image: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
    
}

extension GroupChatViewController: InputBarAccessoryViewDelegate {
    //funkcja wywyloywana jak ktos napisze cokolwiek na chacie
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
       
        microfonButtonStatus(show: text == "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components{
            if let text = component as? String{
               sendMessage(text: text, image: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
    
}



