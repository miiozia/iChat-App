//
//  GroupChatViewController.swift
//  iChat
//
//  Created by Marta Miozga on 28/11/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import PhotosUI
import RealmSwift
import Foundation

class GroupChatViewController: MessagesViewController{
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    var group: Groups!
    
    //mksender
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.userName)
    
    let refreshController = UIRefreshControl()
    
    //message
    var displayMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    //microfon
    let microfonButton = InputBarButtonItem()
    
    //Message
    var mkMessages: [MKMessage] = []
    
    //Realm Message
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    
    //Listeners
    var notificationToken: NotificationToken?
    
    //gallery
    var gallery: GalleryController!
    // var picker = UIImagePickerController()
    
    //gesture recognizer
    var longPressGesture: UILongPressGestureRecognizer!
    
    //audio
    var audioName = ""
    var audioDuration: Date!
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    //MARK: - Inits
    
    init(group: Groups){
        super.init(nibName: nil, bundle: nil)
        self.chatId = group.id
        self.recipientId = group.id
        self.recipientName = group.name
        self.group = group
       
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - VIEWDIDLoad function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        configureLeftBarButtonItem()
        configureTitle()
        
        configureMessageCollecionView()
        configurGestureRecognizer()
        configureMessageInputBar()
        
        loadChats()
        listenNewChats()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseChatFeedback.shared.resetUnreadMessage(chatId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseChatFeedback.shared.resetUnreadMessage(chatId: chatId)
        audioController.stopAnyOngoingPlaying()
        
    }
    //MARK: - CONFIGURATION
    
    private func configureMessageCollecionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configurGestureRecognizer(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureMessageInputBar(){
      //  messageInputBar.isHidden = group.adminID != User.currentId
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        attachButton.tintColor = UIColor(named: "Fill")
        attachButton.setSize(CGSize(width: 25, height: 25), animated: false)
        
        
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        
        microfonButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        microfonButton.tintColor = UIColor(named: "Fill")
        microfonButton.setSize(CGSize(width: 25, height: 25), animated: false)
        microfonButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        microfonButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    
    func microfonButtonStatus(show: Bool){
        if show {
            messageInputBar.setStackViewItems([microfonButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButtonItem(){
        let backButtonImage = UIImage(systemName:  "chevron.left")?.withRenderingMode(.alwaysTemplate)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.backButtonPressed))
        backButton.tintColor = UIColor(named: "Fill")
        
        self.navigationItem.leftBarButtonItem = backButton
        
        // self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureTitle(){
        self.title = group.name
    }
    
    //MARK: - Load Chats
    
    private func loadChats(){
        
        let predicate = NSPredicate(format: "chatRoomID = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        //print("Filtered messages count: \(allLocalMessages.count)")
        if allLocalMessages.isEmpty{
            checkForOldChats()
        }
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            switch changes{
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            case .update(_,_, let insertions, _):
                for index in insertions{
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
                
            case .error(let error): print("error on new insertion", error.localizedDescription)
            }
        })
    }
    
    private func listenNewChats(){
        FirebaseMessage.shared.newChatFirebase(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func  checkForOldChats(){
        FirebaseMessage.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }


    //MARK: - Insert Messages
    
    private func insertMessages(){
        // print("Inserting messages...")
        maxMessageNumber = allLocalMessages.count - displayMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber{
            insertMessage(allLocalMessages[i])
        }

    }
    
    private func insertMessage(_ localMessage: LocalMessage){
        
        let incomingMess = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incomingMess.createMessage(localMessage: localMessage)!)
        displayMessagesCount += 1
    }
    

    
    private func loadMoreMesages(maxNubmer: Int, minNumber: Int){
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0{
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertEarliestMessage(allLocalMessages[i])
        }
    }
    
    private func insertEarliestMessage(_ localMessage: LocalMessage){
        let incomingMess = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incomingMess.createMessage(localMessage: localMessage)!, at: 0)
        displayMessagesCount += 1
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage){
        if localMessage.senderID != User.currentId && localMessage.status != KREAD {
            FirebaseMessage.shared.updateMessageStatus(localMessage, memberIDS: [User.currentId, recipientId])
        }
    }
    
    //MARK: - Actions
    
    func sendMessage(text: String?, image: UIImage?, video: Video?,audio: String?, location: String?, audioDuration: Float = 0.0){
        OutgoingMessage.sendGroupMess(groups: group, text: text, image: image, video: video, audio: audio, location: location)
    }
    
    @objc func backButtonPressed(){
        FirebaseChatFeedback.shared.resetUnreadMessage(chatId: chatId)
        removeListener()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func actionAttachMessage(){
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { alert in
            self.showImageFromGalleryorCamera(camera: true)
        }
        
        let shareGallery = UIAlertAction(title: "Gallery", style: .default) { alert in
            self.showImageFromGalleryorCamera(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { alert in
            if let _ = LocationManager.shared.currentLocation {
                self.sendMessage(text: nil, image: nil, video: nil, audio: nil, location: kLOCATION)
            }else {
                print("No acces to location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //kolorki
        let colorSystemItem = UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1.0)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareGallery.setValue(UIImage(systemName: "photo"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareGallery)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: - scroll
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing{
            if displayMessagesCount < allLocalMessages.count{
                self.loadMoreMesages(maxNubmer: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    
    //MARK: - Helpers
    
    private func removeListener(){
       
        FirebaseMessage.shared.removeListener()
    }
    
    //Adding 1 secound to date, przez filtry z firebase, nie beda wiswtelac sie dwie wiadomosci, tylko jedna jak powinno byc//
    private func lastMessageDate() -> Date{
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    //MARK: - audio messages
    
    @objc func recordAudio(){
        switch longPressGesture.state{
        case .began:
            audioDuration = Date()
            audioName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioName)
        case .ended:
            AudioRecorder.shared.stopRecording()
            
            if filesAtPath(path: audioName + ".m4a"){
                let duration = audioDuration.interval(offComponent: .second, from: Date())
                sendMessage(text: nil, image: nil, video: nil, audio: audioName, location: nil, audioDuration: duration)
            }else {
                print("no audio file")
            }
    audioName = ""
       @unknown default:
            print("unknown gesture")
        }
    }
    
    //MARK: - Gallery
    private func showImageFromGalleryorCamera(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
}
    
    extension GroupChatViewController: GalleryControllerDelegate {
        func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
            if images.count > 0 {
                images.first!.resolve { image in
                    self.sendMessage(text: nil, image: image, video: nil, audio: nil, location: nil)
                }
            }
            
            controller.dismiss(animated: true)
        }
        
        func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
            
            self.sendMessage(text: nil, image: nil, video: video, audio: nil, location: nil)
            controller.dismiss(animated: true)
        }
        
        func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
            controller.dismiss(animated: true)
        }
        
        
        func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
            controller.dismiss(animated: true)
        }
        
    
        
    }
    
    

