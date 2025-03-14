//
//  RecentChatTableViewCell.swift
//  iChat
//
//  Created by Marta Miozga on 13/10/2024.
//

import UIKit

class RecentChatTableViewCell: UITableViewCell {

    //MARK: - IBOUTLET
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadMessView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unreadMessView.layer.cornerRadius = unreadMessView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(recent: ChatManage){
        
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        messageLabel.text = recent.lastMessage
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.9
        messageLabel.numberOfLines = 2 
        
        if recent.unreadCounter != 0 {
            self.unreadMessView.isHidden = false
        }else {
            self.unreadMessView.isHidden = true
        }
        
        setAvatar(avatar: recent.avatar)
        dateLabel.text = timeCalculation(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatar: String){
        if avatar != ""{
            StorageFirebase.downloadImage(imageUrl: avatar) { image in
                self.avatarImageView.image = image?.circleMasked
            }
        }else {
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}
