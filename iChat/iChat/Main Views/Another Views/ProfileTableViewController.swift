//
//  ProfileTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 11/10/2024.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameProfileLabel: UILabel!
    @IBOutlet weak var statusProfileLabel: UILabel!
    
    //MARK: - Vars
    var user: User?
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setUpUI()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "CellColor1")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
            let chatId = newChats(user1: User.currentUser!, user2: user!)
            let privateChatView = ChatViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.userName)
            
            privateChatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatView, animated: true)
        }
    }
    
    //MARK: - set up UI
    
    private  func setUpUI(){
        if user != nil{
            self.title = user!.userName
            usernameProfileLabel.text = user!.userName
            statusProfileLabel.text = user!.status
            if user!.avatar != ""{
                StorageFirebase.downloadImage(imageUrl: user!.avatar) { avatarImage in
                    self.profileImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
}
