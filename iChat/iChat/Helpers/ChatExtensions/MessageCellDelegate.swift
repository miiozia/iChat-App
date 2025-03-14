//
//  MessageCellDelegate.swift
//  iChat
//
//  Created by Marta Miozga on 31/10/2024.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate {
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.imageItem != nil && mkMessage.imageItem!.image != nil {
                //image message
                var images = [SKPhoto]()
                let image = SKPhoto.photoWithImage(mkMessage.imageItem!.image!)
                images.append(image)
                
                let browser = SKPhotoBrowser(photos: images)
                
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                //video message
                
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
                
            }
            
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil{
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}


extension GroupChatViewController: MessageCellDelegate {
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.imageItem != nil && mkMessage.imageItem!.image != nil {
                //image message
                var images = [SKPhoto]()
                let image = SKPhoto.photoWithImage(mkMessage.imageItem!.image!)
                images.append(image)
                
                let browser = SKPhotoBrowser(photos: images)
                
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                //video message
                
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
                
            }
            
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil{
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}


