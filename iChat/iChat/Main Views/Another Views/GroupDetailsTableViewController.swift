//
//  GroupDetailsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 26/11/2024.
//

import UIKit

protocol GroupDetailsTableViewControllerDelegate{
    func didClickFollow()
}

class GroupDetailsTableViewController: UITableViewController {

    
    
    //MARK: - IBACTIONS
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutInfoTextView: UITextField!
    
    //MARK: - vars
    
    var groups: Groups!
    var delegate: GroupDetailsTableViewControllerDelegate?
    
    //MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        showGroupDetails()
        configureRightBarButton()
    }

   
   //MARK: - configiure
    private func showGroupDetails(){
        self.title = groups.name
        nameLabel.text = groups.name
        membersLabel.text = "\(groups.membersIDS.count) Members"
        aboutInfoTextView.text = groups.about
        setAvatar(avatar: groups.avatar)
        
    }
    
    private func configureRightBarButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followGroup))
    }
    
    private func setAvatar(avatar: String){
        if avatar != ""{
            StorageFirebase.downloadImage(imageUrl: avatar) { avatarImage in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        }else {
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
    
    //MARK: - actions
    
    @objc func followGroup(){
        groups.membersIDS.append(User.currentId)
        GroupFeedback.shared.addGroup(groups)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }

}
