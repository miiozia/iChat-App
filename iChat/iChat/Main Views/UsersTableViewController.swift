//
//  UsersTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 06/10/2024.
//

import UIKit

class UsersTableViewController: UITableViewController {

    //MARK: variables
    var allUsers: [User] = []
    var filterUsers: [User] = []
    

    
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        

    // Tworzenie użytkowników testowych
    //         createTestUsers()
        downloadUsers()
        searchControllerFunc()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return searchController.isActive ? filterUsers.count : allUsers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UsersTableViewCell
        
        let user = searchController.isActive ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.configureCell(user: user)
        return cell
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = searchController.isActive ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user)
    }
    
    
    //MARK: - download users
    private func   downloadUsers() {
        DatabaseUserFeedback.shared.downloadAllUsersFromFirebase { allFirebaseUsers in
            self.allUsers = allFirebaseUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: -  searching
    private func searchControllerFunc() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
    }
    
    
    private func filterItemForSearchText(searchText: String){
        filterUsers = allUsers.filter({ user -> Bool in
            return user.userName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: - Scrolling
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing{
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    
    //MARK: - Navigation
    
    private func showUserProfile(_ user: User){
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! ProfileTableViewController
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}

//MARK: - extensions

extension UsersTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterItemForSearchText(searchText: searchController.searchBar.text!)
    }
}
