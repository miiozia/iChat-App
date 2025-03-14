//
//  NewGroupsTableViewController.swift
//  iChat
//
//  Created by Marta Miozga on 24/11/2024.
//

import UIKit
import Gallery
import ProgressHUD

class NewGroupsTableViewController: UITableViewController {

    //MARK: - IBOutlet
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameGroupTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextField!
    
    //MARK: - vars
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatar = ""
    var groupID = UUID().uuidString

    var groupToEdit: Groups?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureGestures()
        
        if groupToEdit != nil{
            configureEditingView()
        }
        configureLeftBarButton()
    }
    

//MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
       
        if nameGroupTextField.text != ""{
            groupToEdit != nil ? editGroup() :   saveGroup()
          
        }else {
            ProgressHUD.showError("Group name is empty")
        }
    }
    
    @objc func avatarImageTap(){
        showGallery()
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - configuration
    
    private func configureGestures(){
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    private func configureEditingView(){
        self.nameGroupTextField.text = groupToEdit!.name
        self.groupID = groupToEdit!.id
        self.avatar = groupToEdit!.avatar
        self.aboutTextView.text = groupToEdit!.about
        self.title = "Edit Group Details"
        
        setAvatar(avatar: groupToEdit!.avatar)
    }
    
   
    
    //MARK: - saveGroup
    private func saveGroup(){
        let group = Groups(id: groupID, name: nameGroupTextField.text!, about: aboutTextView.text!, adminID: User.currentId, membersIDS: [User.currentId], avatar: avatar)
        
        GroupFeedback.shared.addGroup(group)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editGroup(){
        groupToEdit!.name = nameGroupTextField.text!
        groupToEdit!.about = aboutTextView.text!
        groupToEdit?.avatar = avatar
        
        let group = Groups(id: groupID, name: nameGroupTextField.text!, adminID: User.currentId, membersIDS: [User.currentId], avatar: avatar)
        
        GroupFeedback.shared.addGroup(group)
        
        self.navigationController?.popViewController(animated: true)
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
    
    //MARK: avatars
    private func uploadAvatarImage(_ image: UIImage){
        let directory = "avatars/ " + "_\(groupID)" + ".jpg"
        StorageFirebase.imageUpload(image, directory: directory) { documentLink in
            
            self.avatar = documentLink ?? ""
            StorageFirebase.localSaveFile(fileDate: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.groupID)
        }
    }
    
    private func setAvatar(avatar: String){
        if avatar != ""{
            StorageFirebase.downloadImage(imageUrl: avatar) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image?.circleMasked
                    
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
 
}

extension NewGroupsTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first?.resolve(completion: { icon in
                if icon != nil{
                    self.uploadAvatarImage(icon!)
                    self.avatarImageView.image = icon?.circleMasked
                }else {
                    ProgressHUD.showFailed("Could not select image")
                }
            })
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
    
    
}
