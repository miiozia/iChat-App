//
//  UsersTableViewCell.swift
//  iChat
//
//  Created by Marta Miozga on 06/10/2024.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(user: User)
    {
    usernameLabel.text = user.userName
    statusLabel.text = user.status
    setAvatarImage(avatar: user.avatar)
    }
    
    private func setAvatarImage(avatar: String){
        if avatar != ""{
            StorageFirebase.downloadImage(imageUrl: avatar) { (avatarImage) in
                self.avatarImageLabel.image = avatarImage?.circleMasked
            }
        }else {
            self.avatarImageLabel.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}
