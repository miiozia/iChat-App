//
//  ChatsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 27/10/2024.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    
    //MARK: - IBOutlet vars
    
    var allRecents:[ChatManage] = []
    var filterChats:[ChatManage] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        downloadChatsfromFireStore()
        searchControllerFunc()
       
    }
    
    //MARK: - IBActions
    
    @IBAction func composeButton(_ sender: Any) {
        let userView = UIStoryboard.init(name:"Main", bundle: nil).instantiateViewController(identifier: "usersView") as! UsersTableViewController
        navigationController?.pushViewController(userView, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchController.isActive ? filterChats.count :  allRecents.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! RecentChatTableViewCell
        
        let recent = searchController.isActive ? filterChats[indexPath.row] : allRecents[indexPath.row]
        
        print("Chat: \(recent.lastMessage), Sender: \(recent.senderName), Receiver Name: \(recent.receiverName) ")
        
        cell.messageLabel.text = recent.lastMessage
        cell.configure(recent: recent)
        return cell
        
    }
    //MARK: - Table View deleagte\
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,  forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let recent = searchController.isActive ? filterChats[indexPath.row] : allRecents[indexPath.row]
            
            FirebaseChatFeedback.shared.deleteChat(recent)
            
            searchController.isActive ? self.filterChats.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = searchController.isActive ? filterChats[indexPath.row] : allRecents[indexPath.row]
        
        FirebaseChatFeedback.shared.clearUnreadMess(recent: recent)
        
        goToChat(recent: recent)
    }
    
    //MARK: -  download chats
    
    private func downloadChatsfromFireStore() {
        
        FirebaseChatFeedback.shared.downloadRecentChatsFromFireStore { (allChats) in
            
            self.allRecents = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("Pobrano chaty: \(allChats.count), \(allChats.description)")
            }
        }
    }
    
    //MARK: - navigation - go to chat
    
    private func  goToChat(recent: ChatManage){
        restartChat(chatId: recent.chatRoomID, memberIDS: recent.membersIDS)
        let privateChatView = ChatViewController(chatId: recent.chatRoomID, recipientId: recent.receiverID, recipientName: recent.receiverName)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
        
    }
    
    
    
    
    //MARK: - Searching
    
    private func searchControllerFunc() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search chat"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
    }
    
    private func filterItemForSearchText(searchText: String){
        filterChats = allRecents.filter({ recent -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
}

    //MARK: - extensions
extension ChatsTableViewController: UISearchResultsUpdating{
        
func updateSearchResults(for searchController: UISearchController) {
            filterItemForSearchText(searchText: searchController.searchBar.text!)
        }
    }

