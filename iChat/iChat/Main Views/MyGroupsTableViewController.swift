//
//  MyGroupsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 26/11/2024.
//

import UIKit

class MyGroupsTableViewController: UITableViewController {

    
    //MARK: - vars
    var myGropups: [Groups] = []
    
    //MARK: - view didd load
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
       downloadUserGroups()
       

    }
    //MARK: - download groups
    private func downloadUserGroups(){
        GroupFeedback.shared.downloadUsersGroupFromFirebase { allGroups in
            self.myGropups = allGroups
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    //MARK: - IBACTIONS
    
    @IBAction func newGroupButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "myGroupToNewGroup", sender: self)
    }
   
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myGropups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupsTableViewCell
        cell.configure(group: myGropups[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    //MARK: - tablew view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "myGroupToNewGroup", sender: myGropups[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let groupDelete  = myGropups[indexPath.row]
            myGropups.remove(at: indexPath.row)
            GroupFeedback.shared.deleteGroup(groupDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myGroupToNewGroup"{
            let editGroup = segue.destination as! NewGroupsTableViewController
            editGroup.groupToEdit = sender as? Groups
        }
    }
    
}
