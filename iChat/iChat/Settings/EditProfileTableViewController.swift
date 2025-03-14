//
//  EditProfileTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 03/10/2024.
//

import UIKit
import YPImagePicker
import Gallery
import ProgressHUD
class EditProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var statusEditProfileLabel: UILabel!
    
    //MARK: - IBActions
    
    @IBAction func editButtonPress(_ sender: Any) {
        showGallery() }
    
    //MARK: -  Vars
    
    var gallery: GalleryController!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfoStatus()
    }
    
        //MARK: -  Table view Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "backgroundColorTable")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editProfileToStatusSeg", sender: self)
        }
    }
    
//MARK: - Update UI
    
    private func showUserInfoStatus() {
        if let user = User.currentUser{
            userNameTextField.text = user.userName
            statusEditProfileLabel.text = user.status
            
            if user.avatar != ""{
                StorageFirebase.downloadImage(imageUrl: user.avatar) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: - configure
    
    private func configureTextField(){
        userNameTextField.delegate = self
        userNameTextField.clearButtonMode = .whileEditing
    }

    //MARK: - gallery
    
    private func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - Uploading Images

    private func uploadAvatar(_ image: UIImage){
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        StorageFirebase.imageUpload(image, directory: fileDirectory) { (avatar) in
            if var user = User.currentUser{
                user.avatar = avatar ?? ""
                savingUserData(user)
                DatabaseUserFeedback.shared.savingUserInFirestore(user)
            }
            
        StorageFirebase.localSaveFile(fileDate: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }
}

//MARK: -  extensions

extension EditProfileTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField{
            if textField.text != ""{
                if var user = User.currentUser{
                    user.userName = textField.text!
                    savingUserData(user)
                    DatabaseUserFeedback.shared.savingUserInFirestore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true 
    }
}





extension EditProfileTableViewController : GalleryControllerDelegate{
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0{
            images.first!.resolve { (avatarImage) in
                if avatarImage != nil {
                    self.uploadAvatar(avatarImage!)
                    self.avatarImageView.image = avatarImage
                }else {
                    ProgressHUD.showError("Could not select image")
                }
               
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
