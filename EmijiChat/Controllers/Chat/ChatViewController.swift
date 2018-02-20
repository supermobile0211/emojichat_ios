//
//  ChatViewController.swift
//  EmijiChat
//
//  Created by Bender on 28.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import MobileCoreServices
import JSQMessagesViewController
import Firebase

import FLAnimatedImage

import Kingfisher

final class ChatViewController: JSQMessagesViewController, MuslimEmojiKeyboardDelegate {

    @IBOutlet weak var friendPhotoImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendLastSeenLabel: UILabel!
    
    let manager = CLLocationManager()
    
    var friend: User!
    var friendID: String?
    var friendPhone: String?
    var friendPhotoURL: String = ""
    
    var messages = [JSQMessage]()
    
    var imagePicker: UIImagePickerController!
    
    var forwardMessage: FBMessage?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // Custom keyboard
    var muslimEmojiKeyboard: MuslimEmojiKeyboard!
    
    private var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        
        if let userID = Auth.auth().currentUser?.uid {
            senderId = userID
        }
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            senderDisplayName = username
        }

        databaseRef = Database.database().reference()
        
        // initialize custom keyboard
        muslimEmojiKeyboard = MuslimEmojiKeyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 253))
        muslimEmojiKeyboard.delegate = self
        
        configureInputToolbar()
        
        createChatOrDownloadMessages()
        
        getIndividualRoomID()
        
        markAllAsReaded()
        
        configureNavBarView()
        
        FirebaseManager.shared.getUserByID(id: friendID!) { user in
            self.friend = user
        }
    }
    
    private func markAllAsReaded() {
        
        guard let friendID = friendID, let senderId = senderId else {
            return
        }
        
        let senderRef = databaseRef.child("users").child(senderId).child("dialogs").child("individual_\(friendID)")
        senderRef.updateChildValues(["lastSeenDate": Date().timeIntervalSince1970])
    }
    
    private func createChatOrDownloadMessages() {
        Database.database().reference().child("users").child(senderId).child("dialogs").child("individual_\(friendID)").observe(.value, with: { (snapshot) in
            // Get friends IDs
            let value = snapshot.value as? NSDictionary
            print(value)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func configureNavBarView() {
        guard let friendID = friendID else {
            return
        }
        
        databaseRef.child("users").child(friendID).observeSingleEvent(of: .value, with: { userSnapshot in
            let userJson = userSnapshot.value as? NSDictionary
            
            if
                let username = userJson?.value(forKey: "username") as? String,
                let friendPhone = userJson?.value(forKey: "phone") as? String,
                let lastSeen = userJson?.value(forKey: "lastSeen") as? Double
            {
                self.friendNameLabel.text = username
                self.friendPhone = friendPhone
                

                let date = Date(timeIntervalSince1970: lastSeen)
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mma"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                let dataString = formatter.string(from: date)
                self.friendLastSeenLabel.text = "Last seen " + dataString
                
                
                
                if let photo = userJson?.value(forKey: "photo") as? String {
                    if !photo.isEmpty {
                        let url = URL(string: photo)
                        self.friendPhotoURL = photo
                        self.friendPhotoImageView.kf.indicatorType = .activity
                        self.friendPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func configureInputToolbar() {
        let sendButton = UIButton(frame: CGRect(x: 50, y: 2, width: 32, height: 32))
        sendButton.setImage(UIImage(named: "send_btn"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send_btn"), for: .normal)// = UIImage(named: "send_btn")// = sendButton
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.imageEdgeInsets.left = 30
        //        self.inputToolbar.contentView.rightBarButtonItem.isHidden = true//sendButton
        
        let smileButton = UIButton(frame: CGRect(x: 0, y: 2, width: 28, height: 28))
        smileButton.setImage(UIImage(named: "emoji"), for: .normal)
        smileButton.addTarget(self, action:#selector(didPressSmileButton(_:)), for: .touchUpInside)
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(smileButton)
        //        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(sendButton)
        
        let attachButton = UIButton(frame: CGRect(x: 0, y: 2, width: 28, height: 28))
        attachButton.setImage(UIImage(named: "attach"), for: .normal)
        attachButton.addTarget(self, action:#selector(didPressAccessoryButton(_:)), for: .touchUpInside)
        self.inputToolbar.contentView.leftBarButtonItem.isHidden = true
        self.inputToolbar.contentView.leftBarButtonContainerView.addSubview(attachButton)
        
        self.inputToolbar.contentView.leftBarButtonItemWidth = 30
        self.inputToolbar.contentView.rightBarButtonItemWidth = 62
    }
    
    // required method for MuslimEmojiKeyboardDelegate delegate protocol
    func keyWasTapped(emojiImage: UIImage) {
        let photoItem = JSQPhotoMediaItem(image: emojiImage)
//        self.addMedia(photoItem!)
    }
    
    func emojiTapped(emojiName: String) {
        print(emojiName)
        self.sendMessageToFirebase(message: "(\(emojiName))", type: "Text", individualRoomID: individualRoomID)
    }
    
    func keyWasTapped(gifImageName: String) {
        let photoItem = JSQPhotoMediaItem(image: UIImage())
        
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: gifImageName, withExtension: "gif")!)
        let image: FLAnimatedImage = FLAnimatedImage(animatedGIFData: imageData)
        let imageView: FLAnimatedImageView = FLAnimatedImageView()
        imageView.animatedImage = image
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        photoItem?.mediaView().addSubview(imageView)
//        self.addMedia(photoItem!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let forwardMessage = forwardMessage {
            self.sendMessageToFirebase(message: forwardMessage.messageText, type: forwardMessage.type, individualRoomID: individualRoomID)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func videoCallButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "VideoCallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"VideoCallViewController") as! VideoCallViewController
        // TODO: ☺️☺️☺️ 👀👀👀 sdg
//        viewController.friend = friend
        UIApplication.shared.statusBarView?.backgroundColor = .clear//Constants.UI.barColor
        self.present(viewController, animated: true)
    }
    
    @IBAction func voiceCallButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "CallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"CallViewController") as! CallViewController
//        viewController.friend = friend
        UIApplication.shared.statusBarView?.backgroundColor = .clear//Constants.UI.barColor
        self.present(viewController, animated: true)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 103/255, green: 209/255, blue: 89/255, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red: 230/255, green: 250/255, blue: 252/255, alpha: 1))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let messageFB = messagesFB[indexPath.row]
        return NSAttributedString(string: messageFB.dataSentString())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        /*if indexPath.row == 2 {
            return NSAttributedString(string: "Today")
        }*/
        return nil
    }
    /*
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "03:47AM")
    }
    */
    /*
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row == 2 {
            return 60
        }
        return 5
    }
    */
    /*
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let superSize: CGSize = super.collectionView.collectionViewLayout.sizeForItem(at: indexPath)
        
        if indexPath.row == 3 {
            return CGSize(width: superSize.width, height: 100)
        }
        
        return superSize
    }
    */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    /*
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as?  JSQMessagesCollectionViewCell
        
        let message = self.messages[indexPath.item]
        
        if message.isMediaMessage {
            cell?.mediaView.contentMode = .scaleAspectFit
            /*
            let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "emoji_0_0_11", withExtension: "gif")!)
                let image: FLAnimatedImage = FLAnimatedImage(animatedGIFData: imageData)
                let imageView: FLAnimatedImageView = FLAnimatedImageView()
                imageView.animatedImage = image
                imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//                cell?.mediaView.addSubview(imageView)
            message.media.mediaView().addSubview(imageView)*/
        } else {
            cell?.textView.textColor = .black
            cell?.textView.layer.cornerRadius = 10
            /*
            if indexPath.row == 0 {
                cell?.cellBottomLabel.textInsets.left = 40
            } else {
                cell?.cellBottomLabel.textInsets.right = 40
            }*/
        }
        
        var photoURL = ""
        if message.senderId == self.senderId {
            photoURL = UserDefaults.standard.string(forKey: "avatarDownloadURL") ?? ""
        } else {
            photoURL = friendPhotoURL
        }
        
        if !photoURL.isEmpty {
            let url = URL(string: photoURL)
            cell?.avatarImageView.kf.indicatorType = .activity
            cell?.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            self.messagesFB[indexPath.row].isUserAvatarDownloaded = true
        }

        return cell!
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
                    FirebaseManager.shared.deleteSingleChatMessage(withKey: self.messagesFB[indexPath.row].key, friendID: self.friendID!)
                    if let username = UserDefaults.standard.string(forKey: "username") {
                        self.messagesFB[indexPath.row].messageText = username + " deleted a message"
                    }
                    self.collectionView.reloadData()
                }
                sheet.addAction(deleteForMyselfAction)
                
                let deleteForEveryoneAction = UIAlertAction(title: "Delete for everyone", style: .default) { (action) in
                    FirebaseManager.shared.deleteSingleChatMessage(withKey: self.messagesFB[indexPath.row].key, friendID: self.friendID!)
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
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        //return nil
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    var individualRoomID: String = ""
    
    private func getIndividualRoomID() {
        guard let friendID = friendID, let senderId = senderId else {
            return
        }
        
        databaseRef.child("messages").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(senderId + "_" + friendID) {
                self.individualRoomID = senderId + "_" + friendID
            } else {
                self.individualRoomID = friendID + "_" + senderId
            }
            self.observeNewMessages()
        })
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        self.sendMessageToFirebase(message: text, type: "Text", individualRoomID: individualRoomID)
//        messages.append(message!)
        
//        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
//        finishSendingMessage() // 5
    }
    
    fileprivate func sendMessageToFirebase(message: String, type: String, individualRoomID: String) {
        guard let friendID = friendID, let senderId = self.senderId else {
            return
        }
        
        let dialogRef = databaseRef.child("messages").child(individualRoomID).childByAutoId()
        dialogRef.setValue([
            "dateSent": Date().timeIntervalSince1970,
            "message": message,
            "type": type,
            "userID": senderId,
            ])
 
        let senderRef = databaseRef.child("users").child(senderId).child("dialogs").child("individual_\(friendID)")
        let friendRef = databaseRef.child("users").child(friendID).child("dialogs").child("individual_\(senderId)")
        
        senderRef.setValue(["dialogID": "individual_\(friendID)",
            "lastMessage": message,
            "lastMessageDateSent": Date().timeIntervalSince1970,
            "lastMessageType": type,
            "lastSeenDate": Date().timeIntervalSince1970,
            "occupantsIds": [friendID],
            "type": "Individual"
            ])
        
        friendRef.setValue(["dialogID": "individual_\(senderId)",
            "lastMessage": message,
            "lastMessageDateSent": Date().timeIntervalSince1970,
            "lastMessageType": type,
            "lastSeenDate": 0,//Date().timeIntervalSince1970,
            "occupantsIds": [senderId],
            "type": "Individual"
            ])
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            FirebaseManager.shared.sendNotification(title: username, message: message, userToken: friend.pushToken!)
        }
        
        
    }
    
    var messagesFB: [FBMessage] = []
    
    private func observeNewMessages() {
        guard let friendID = friendID else {
            return
        }
        
        let dialogRef = databaseRef.child("messages").child(individualRoomID)
        dialogRef.observe(.childAdded, with: { (newMessage) in
            // Get friends IDs
            let newMessageJson = newMessage.value as? NSDictionary
            print(newMessageJson)
            
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
//                    let image = UIImage(named: emojiName)
//                    let photoItem = JSQPhotoMediaItem(image: image)
//                    message = JSQMessage(senderId: senderID, displayName: self.senderDisplayName, media: photoItem)
                    let photoItem = JSQPhotoMediaItem(image: UIImage())
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
    
    var isSystemKeyboard = true
    func didPressSmileButton(_ sender: UIButton) {
        self.keyboardController.textView.inputView = nil
        if isSystemKeyboard {
            self.keyboardController.textView.inputView = muslimEmojiKeyboard
        }
        self.keyboardController.textView.reloadInputViews()
        isSystemKeyboard = !isSystemKeyboard
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
        
        let photoVideoAction = UIAlertAction(title: "Photo & Video Library", style: .default) { (action) in
            // Open photo library
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]//["public.image", "public.movie"]
            
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let image = UIImage(named:"profile")!
        let avatar = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(image.size.width/2))
        return avatar
    }
    
    @IBAction func navBarUserProfileButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FriendProfileViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"FriendProfileViewController") as! FriendProfileViewController
        viewController.friendPhotoURL = friendPhotoURL
        viewController.friendName = friendNameLabel.text ?? ""
        viewController.friendMobilePhone = friendPhone ?? ""
        viewController.friendID = friendID
        self.hidesBottomBarWhenPushed = false
        viewController.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(viewController, animated: true)
        self.hidesBottomBarWhenPushed = true
    }
    
    var storageRef: StorageReference = Storage.storage().reference()
}

import CoreLocation

extension ChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            self.sendMessageToFirebase(message: location.coordinate.latitude.description + "/" + location.coordinate.longitude.description, type: "Location", individualRoomID: self.individualRoomID)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

import SVProgressHUD

extension ChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func addMedia(_ avatarDownloadURL: URL) {
        self.sendMessageToFirebase(message: avatarDownloadURL.absoluteString, type: "Photo", individualRoomID: self.individualRoomID)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            // load video to firebase
            
            // we selected a video
            print("Here's the file URL: ", videoURL)
            /*
            // Where we'll store the video:
            let storageReference = FIRStorage.storage().reference().child("video.mov")
            
            // Start the video storage process
            storageReference.putFile(videoURL as URL, metadata: nil, completion: { (metadata, error) in
                if error == nil {
                    print("Successful video upload")
                } else {
                    print(error?.localizedDescription)
                }
            })
            */
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
        
        let avatarImagesRef = storageRef.child("images/chat/" + Auth.auth().currentUser!.uid + Date().timeIntervalSince1970.description + ".jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        SVProgressHUD.show(withStatus: "Uploading photo...")
        avatarImagesRef.putData(imageData, metadata: metadata) { (metadata, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            // avatar uploaded
            if let avatarDownloadURL = metadata?.downloadURL()?.absoluteURL {
                // load image to firebase
                self.addMedia(avatarDownloadURL)
            }
        }

    }
    
}

struct FBMessage {
    var messageText: String
    var senderID: String
    var dataSent: Double
    var type: String
    var isUserAvatarDownloaded: Bool
    var key: String
    
    func dataSentString() -> String {
        let date = Date(timeIntervalSince1970: dataSent)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
}
