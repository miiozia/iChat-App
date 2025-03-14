//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 03/10/2024.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    
    //MARK: - View LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "backgroundColorTable")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 5.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0{
            performSegue(withIdentifier: "settingsToEditProfileSeg", sender: self)
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func shareButton(_ sender: Any) {
       print("shareButton")
        
    }
    
    
    @IBAction func infoButton(_ sender: Any) {
        
       let infoViewController = UIViewController()
           infoViewController.view.backgroundColor = .white

           let infoLabel = UILabel()
           infoLabel.text = "Aplikacja inżynierska do komunikacji z wykorzystaniem szyfrowania end-to-end. Autor: Marta Miozga"
           infoLabel.numberOfLines = 0
           infoLabel.textAlignment = .center
           infoLabel.translatesAutoresizingMaskIntoConstraints = false
           infoViewController.view.addSubview(infoLabel)

           NSLayoutConstraint.activate([
               infoLabel.centerXAnchor.constraint(equalTo: infoViewController.view.centerXAnchor),
               infoLabel.topAnchor.constraint(equalTo: infoViewController.view.topAnchor, constant: 100),
               infoLabel.leadingAnchor.constraint(equalTo: infoViewController.view.leadingAnchor, constant: 20),
               infoLabel.trailingAnchor.constraint(equalTo: infoViewController.view.trailingAnchor, constant: -20)
           ])

           let closeButton = UIButton(type: .system)
           closeButton.setTitle("Zamknij", for: .normal)
           closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
           closeButton.translatesAutoresizingMaskIntoConstraints = false

           if let fillColor = UIColor(named: "Fill") {
               closeButton.setTitleColor(fillColor, for: .normal)
           }

           closeButton.addTarget(self, action: #selector(dismissInfoView), for: .touchUpInside)
           infoViewController.view.addSubview(closeButton)

           NSLayoutConstraint.activate([
               closeButton.centerXAnchor.constraint(equalTo: infoViewController.view.centerXAnchor),
               closeButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20)
           ])

           present(infoViewController, animated: true, completion: nil)
       }
    
    @objc func dismissInfoView() {
        if let presentingVC = self.presentingViewController {
               presentingVC.dismiss(animated: true, completion: nil)
           } else {
               dismiss(animated: true, completion: nil)
           }
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        print("Wywołano logOutButton.")
        
                DatabaseUserFeedback.shared.logOutUser { error in
                    if error == nil {
                        print("Wylogowanie zakończone sukcesem.")
                        let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                        DispatchQueue.main.async {
                                loginView.modalPresentationStyle = .fullScreen
                                self.present(loginView, animated: true, completion: nil)
                                print("Ekran logowania został zaprezentowany.")
                            }
                        
                    }
                }
    }
    
   
    
    
    //MARK: - UpdateUI
    private func showUserInfo(){
        if let user = User.currentUser {
            usernameOutlet.text = user.userName
            statusLabel.text = user.status
            appVersionLabel.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatar != "" {
                StorageFirebase.downloadImage(imageUrl: user.avatar) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    
    
}
