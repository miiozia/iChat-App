//
//  GroupsTableViewCell.swift
//  iChat
//
//  Created by Marta Miozga on 24/11/2024.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {

    
    //MARK: - Labels and Images - IBOUTLETS
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var abouLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
   
    
    func configure(group: Groups){
        nameLabel.text = group.name
        abouLabel.text = group.about
        membersLabel.text = "\(group.membersIDS.count) members"
        dateLabel.text = timeCalculation(group.lastMessageDate ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
        setAvatar(avatar: group.avatar)
        
    }
    
    private func setAvatar(avatar: String){
        if avatar != ""{
            StorageFirebase.downloadImage(imageUrl: avatar) { avatarImage in
                DispatchQueue.main.async {
                    self.avatarImage.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        }else {
            self.avatarImage.image = UIImage(named: "avatar")?.circleMasked
        }
    }

}
