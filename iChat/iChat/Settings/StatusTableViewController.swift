//
//  StatusTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 06/10/2024.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    //MARK: -  Vars
    
    var allStatuses: [String] = []
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let status = allStatuses[indexPath.row]
        cell.textLabel?.text = status
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateStatusSell(indexPath)
        tableView.reloadData()
        
    }
    
   //MARK: - loading

    private func loadUserStatus(){
        allStatuses = userDefaults.object(forKey: kSTATUS) as! [String]
        tableView.reloadData()
    }
    
    private func updateStatusSell(_ indexPath: IndexPath){
        if var user = User.currentUser{
            user.status = allStatuses[indexPath.row]
            savingUserData(user)
            DatabaseUserFeedback.shared.savingUserInFirestore(user)
        }
    }
}
