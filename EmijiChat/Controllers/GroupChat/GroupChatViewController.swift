//
//  GroupChatViewController.swift
//  EmijiChat
//
//  Created by Bender on 05.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import MobileCoreServices
import FLAnimatedImage
import Kingfisher
import SVProgressHUD

final class GroupChatViewController: JSQMessagesViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var groupPhotoImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupSubjectLabel: UILabel!
    
    var chat: Chat = Chat()
    var chatMembers: [User] = []
    var messages = [JSQMessage]()
    
    var messagesFB: [FBMessage] = []
    var databaseRef: DatabaseReference = Database.database().reference()
    var storageRef: StorageReference = Storage.storage().reference()
    
    var imagePicker: UIImagePickerController!
    
    let manager = CLLocationManager()
    
    // Custom keyboard
    var muslimEmojiKeyboard: MuslimEmojiKeyboard!
    var isSystemKeyboard = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        
        if let userID = FirebaseManager.shared.getCurrentUserID() {
            senderId = userID
        }
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            senderDisplayName = username
        }
        
        configureCustomKeyboard()
        configureInputToolbar()
        configureNavBarView()
        observeNewMessages()
//        addLongPressGestureRecognizer()
    }
    
    /*
    private func addLongPressGestureRecognizer() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GroupChatViewController.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = self.collectionView.indexPathForItem(at: touchPoint) {
                let sheet = MyUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                if messagesFB[indexPath.row].type == "Text" {
                    let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
                        UIPasteboard.general.string = self.messagesFB[indexPath.row].messageText
                    }
                    sheet.addAction(copyAction)
                }
                
                let forwardAction = UIAlertAction(title: "Forward", style: .default) { (action) in
                    let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"ContactsViewController") as! ContactsViewController
                    viewController.forwardMessage = self.messagesFB[indexPath.row]
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                sheet.addAction(forwardAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    
                }
                sheet.addAction(deleteAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                sheet.addAction(cancelAction)
                
                self.present(sheet, animated: true, completion: nil)
            }
        }
    }
    */
    
    private func configureCustomKeyboard() {
        // initialize custom keyboard
        muslimEmojiKeyboard = MuslimEmojiKeyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 253))
        muslimEmojiKeyboard.delegate = self
    }
    
    private func configureInputToolbar() {
        // Send Button
        let sendButton = UIButton(frame: CGRect(x: 50, y: 2, width: 32, height: 32))
        sendButton.setImage(UIImage(named: "send_btn"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send_btn"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.imageEdgeInsets.left = 30
        // Smile button
        let smileButton = UIButton(frame: CGRect(x: 0, y: 2, width: 28, height: 28))
        smileButton.setImage(UIImage(named: "emoji"), for: .normal)
        smileButton.addTarget(self, action:#selector(didPressSmileButton(_:)), for: .touchUpInside)
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(smileButton)
        // Attach button
        let attachButton = UIButton(frame: CGRect(x: 0, y: 2, width: 28, height: 28))
        attachButton.setImage(UIImage(named: "attach"), for: .normal)
        attachButton.addTarget(self, action:#selector(didPressAccessoryButton(_:)), for: .touchUpInside)
        self.inputToolbar.contentView.leftBarButtonItem.isHidden = true
        self.inputToolbar.contentView.leftBarButtonContainerView.addSubview(attachButton)
        // Change content width
        self.inputToolbar.contentView.leftBarButtonItemWidth = 30
        self.inputToolbar.contentView.rightBarButtonItemWidth = 62
    }
    
    private func configureNavBarView() {
        if !chat.photo.isEmpty {
            let url = URL(string: chat.photo)
            groupPhotoImageView.kf.indicatorType = .activity
            groupPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        groupSubjectLabel.text = chat.subject
        groupNameLabel.text = chat.title
    }
    
    @IBAction func showGroupSettingsButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupDescribeViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"GroupDescribeViewController") as! GroupDescribeViewController
        viewController.groupName = groupNameLabel.text!
        viewController.groupSubject = groupSubjectLabel.text!
        viewController.groupImage = groupPhotoImageView.image
        viewController.groupParcipiants = chat.occupantsIds
        viewController.groupID = chat.dialogID
        viewController.group = chat
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension GroupChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let messageFB = messagesFB[indexPath.row]
        return NSAttributedString(string: messageFB.dataSentString())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        if messages[indexPath.item].senderId == senderId {
            return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 103/255, green: 209/255, blue: 89/255, alpha: 1))
        } else {
            return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red: 230/255, green: 250/255, blue: 252/255, alpha: 1))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messagesFB[indexPath.row]
        print(message.messageText)
        
        let sheet = MyUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //if messagesFB[indexPath.row].type == "Text" {
            let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
                UIPasteboard.general.string = message.messageText
            }
            sheet.addAction(copyAction)
        //}
        
        let forwardAction = UIAlertAction(title: "Forward", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"ContactsViewController") as! ContactsViewController
            viewController.forwardMessage = message
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        sheet.addAction(forwardAction)
        
        if message.senderID == senderId {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                let sheet = MyUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let deleteForMyselfAction = UIAlertAction(title: "Delete for myself", style: .default) { (action) in
                    FirebaseManager.shared.deleteGroupMessage(withKey: message.key, inRoom: self.chat.dialogID, chatMembers: self.chat.occupantsIds)
                    if let username = UserDefaults.standard.string(forKey: "username") {
                        self.messagesFB[indexPath.row].messageText = username + " deleted a message"
                    }
                    self.collectionView.reloadData()
                }
                sheet.addAction(deleteForMyselfAction)
                
                let deleteForEveryoneAction = UIAlertAction(title: "Delete for everyone", style: .default) { (action) in
                    FirebaseManager.shared.deleteGroupMessage(withKey: message.key, inRoom: self.chat.dialogID, chatMembers: self.chat.occupantsIds)
                    if let username = UserDefaults.standard.string(forKey: "username") {
                        self.messagesFB[indexPath.row].messageText = username + " deleted a message"
                    }
                    self.collectionView.reloadData()
                }
                sheet.addAction(deleteForEveryoneAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                sheet.addAction(cancelAction)
                
                self.present(sheet, animated: true, completion: nil)
            }
            sheet.addAction(deleteAction)
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        FirebaseManager.shared.sendMessage(withText: text, type: "Text", chat: chat)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let sheet = MyUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            // Open camera
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        sheet.addAction(cameraAction)
        
        let photoVideoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            // Open photo library
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String/*, kUTTypeMovie as String*/]
            
            self.imagePicker.navigationBar.isTranslucent = false
            self.imagePicker.navigationBar.barTintColor = Constants.UI.barColor
            self.imagePicker.navigationBar.tintColor = .white
            self.imagePicker.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.white
            ]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        sheet.addAction(photoVideoAction)
        
        let locationAction = UIAlertAction(title: "Location", style: .default) { (action) in
            // Get location
            self.manager.requestLocation()
        }
        sheet.addAction(locationAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as?  JSQMessagesCollectionViewCell
        
        let message = self.messages[indexPath.item]
        
        if message.isMediaMessage {
            cell?.mediaView.contentMode = .scaleAspectFit
        } else {
            cell?.textView.textColor = .black
            cell?.textView.layer.cornerRadius = 10
        }
        
        var photoURL = ""
        if message.senderId == self.senderId {
            photoURL = UserDefaults.standard.string(forKey: "avatarDownloadURL") ?? ""
        } else {
            if let index = chatMembers.index(where: { $0.id == "dsf" }) {
                if let photo = chatMembers[index].photo {
                    photoURL = photo
                }
            }
        }
        
        if !photoURL.isEmpty {
            let url = URL(string: photoURL)
            cell?.avatarImageView.kf.indicatorType = .activity
            cell?.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            self.messagesFB[indexPath.row].isUserAvatarDownloaded = true
        }
        
        return cell!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let image = UIImage(named:"profile")!
        let avatar = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(image.size.width/2))
        return avatar
    }
}

import CoreLocation

extension GroupChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            FirebaseManager.shared.sendMessage(withText: location.coordinate.latitude.description + "/" + location.coordinate.longitude.description, type: "Location", chat: chat)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension GroupChatViewController: MuslimEmojiKeyboardDelegate {
    func keyWasTapped(emojiImage: UIImage) { }
    
    func keyWasTapped(gifImageName: String) { }
    
    func emojiTapped(emojiName: String) {
        FirebaseManager.shared.sendMessage(withText: "(\(emojiName))", type: "Text", chat: chat)
    }
    
    func didPressSmileButton(_ sender: UIButton) {
        self.keyboardController.textView.inputView = nil
        if isSystemKeyboard {
            self.keyboardController.textView.inputView = muslimEmojiKeyboard
        }
        self.keyboardController.textView.reloadInputViews()
        isSystemKeyboard = !isSystemKeyboard
    }
}

extension GroupChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func addMedia(_ imageURL: URL) {
        FirebaseManager.shared.sendMessage(withText: imageURL.absoluteString, type: "Photo", chat: chat)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImageToFB(image: image)
        } else {
            print("Error while take photo/video")
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFB(image: UIImage) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let imageRef = storageRef.child("images/chat/" + FirebaseManager.shared.getCurrentUserID()! + Date().timeIntervalSince1970.description + ".jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        SVProgressHUD.show(withStatus: "Uploading photo...")
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            if let imageURL = metadata?.downloadURL()?.absoluteURL {
                // load image to firebase
                self.addMedia(imageURL)
            }
        }
        
    }
    
}

extension GroupChatViewController {
    
    fileprivate func observeNewMessages() {
        let dialogRef = databaseRef.child("messages").child(chat.dialogID)
        dialogRef.observe(.childAdded, with: { (newMessage) in
            let newMessageJson = newMessage.value as? NSDictionary
            
            if
                let messageText = newMessageJson?.value(forKey: "message") as? String,
                let senderID = newMessageJson?.value(forKey: "userID") as? String,
                let dataSent = newMessageJson?.value(forKey: "dateSent") as? Double,
                let type = newMessageJson?.value(forKey: "type") as? String
            {
                
                self.messagesFB.append(FBMessage(messageText: messageText, senderID: senderID, dataSent: dataSent, type: type, isUserAvatarDownloaded: false, key: newMessage.key))
                
                var message: JSQMessage!
                
                if type == "Location" {
                    let locationArr = messageText.components(separatedBy: "/")
                    
                    let latitude    = locationArr[0]
                    let longitude   = locationArr[1]
                    
                    let location = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
                    
                    let locationItem: JSQLocationMediaItem = JSQLocationMediaItem(location: location)
                    
                    message = JSQMessage(senderId: senderID, displayName: self.senderDisplayName, media: locationItem)
                    
                } else if type == "Photo" {
                    let photoItem = AsyncPhotoMediaItem(withURL: URL(string: messageText)!, imageSize: CGSize(width: 250, height: 250), isOperator: true)
                    message = JSQMessage(senderId: senderID, displayName: self.senderDisplayName, media: photoItem)
                } else if messageText.contains("(emoji_") {
                    var emojiName = messageText.replacingOccurrences(of: "(", with: "")
                    emojiName = emojiName.replacingOccurrences(of: ")", with: "")
                    let image = UIImage(named: emojiName)
                    let photoItem = JSQPhotoMediaItem(image: image)
                    message = JSQMessage(senderId: senderID, displayName: self.senderDisplayName, media: photoItem)
                } else if messageText.contains("(keyboard_") {
                    let photoItem = JSQPhotoMediaItem(image: UIImage())
                    
                    var emojiName = messageText.replacingOccurrences(of: "(", with: "")
                    emojiName = emojiName.replacingOccurrences(of: ")", with: "")
                    emojiName = emojiName.replacingOccurrences(of: "keyboard", with: "emoji")
                    
                    let imageData = try! Data(contentsOf: Bundle.main.url(forResource: emojiName, withExtension: "gif")!)
                    let image: FLAnimatedImage = FLAnimatedImage(animatedGIFData: imageData)
                    let imageView: FLAnimatedImageView = FLAnimatedImageView()
                    imageView.animatedImage = image
                    imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
                    
                    if let center = photoItem?.mediaView().center {
                        imageView.center = center
                    }
                    
                    photoItem?.mediaView().addSubview(imageView)
                    message = JSQMessage(senderId: senderID, displayName: self.senderDisplayName, media: photoItem)
                } else {
                    message = JSQMessage(senderId: senderID, displayName: senderID, text: messageText)
                }
                
                
                self.messages.append(message!)
                JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
                self.finishSendingMessage() // 5
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
