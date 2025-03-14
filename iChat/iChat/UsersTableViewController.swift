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
    
    //MARK: view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createTestUsers()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return searchController.isActive ? filterUsers.count : allUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        
        let user = searchController.isActive ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.configureCell(user: user)
        return cell
    }
   
}
