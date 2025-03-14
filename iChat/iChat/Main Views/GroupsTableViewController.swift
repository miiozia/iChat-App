//
//  GroupsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 24/11/2024.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var groupSegmentOutlet: UISegmentedControl!

    //MARK: - vars
    
    var allGroups: [Groups] = []
    var subscribedGroups: [Groups] = []
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Groups"
        
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        tableView.tableFooterView = UIView()
        
        downloadAllGroups()
        downloadSubGroups()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSegmentOutlet.selectedSegmentIndex == 0 ? subscribedGroups.count : allGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupsTableViewCell
        
        let groups = groupSegmentOutlet.selectedSegmentIndex == 0 ? subscribedGroups[indexPath.row] : allGroups[indexPath.row]
        cell.configure(group: groups)
        return cell
    }

    
    //MARK: - download  groups
    private func  downloadAllGroups(){
        GroupFeedback.shared.downloadAllGroups { allGroups in
            self.allGroups = allGroups
            
            if self.groupSegmentOutlet.selectedSegmentIndex == 1{
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
            
        }
            
    }
    
    private func downloadSubGroups(){
        GroupFeedback.shared.downloadSubscribedGroups { subscribedGroups in
            self.subscribedGroups = subscribedGroups
            if self.groupSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
        }
    }
    }
    
    
    //MARK: - tabke view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if groupSegmentOutlet.selectedSegmentIndex ==  1{
            showGroupView(groups: allGroups[indexPath.row])
            
        } else {
            showChatView(groups: subscribedGroups[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if groupSegmentOutlet.selectedSegmentIndex == 1{
            return false
        }else {
            return subscribedGroups[indexPath.row]
                .adminID != User.currentId
        }
        
            
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            var groupsToUnsubscribed = subscribedGroups[indexPath.row]
            subscribedGroups.remove(at: indexPath.row)
            
            
            if let index = groupsToUnsubscribed.membersIDS.firstIndex(of: User.currentId){
                groupsToUnsubscribed.membersIDS.remove(at: index)
            }
           
            
            GroupFeedback.shared.addGroup(groupsToUnsubscribed)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

//MARK: - IBACTIONS
    
    @IBAction func groupSegmentAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    
  //MARK: - scroll view delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing{
            self.downloadAllGroups()
            self.refreshControl!.endRefreshing()
        }
    }
    
        //MARK: - navigations
    
    private func showGroupView(groups: Groups){
        
        let groupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupView") as! GroupDetailsTableViewController
        
        groupVC.groups = groups
        groupVC.delegate = self
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    
    private func showChatView(groups: Groups){
        let groupChatVC = GroupChatViewController(group: groups)
        groupChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupChatVC, animated: true)
    }

}

extension GroupsTableViewController: GroupDetailsTableViewControllerDelegate{
    func didClickFollow() {
        self.downloadAllGroups()
    }
    
    
}
