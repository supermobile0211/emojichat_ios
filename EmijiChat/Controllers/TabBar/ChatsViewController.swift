//
//  ChatsViewController.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

struct Chat {
    var occupantsIds: [String] = []
    var lastMessageType: String = ""
    var dialogID: String = ""
    var lastMessage: String = ""
    var lastMessageDateSent: Double = 0.0
    var type: String = ""
    var lastSeenDate: Double = 0.0
    var unreadedMessages: Int = 0
    
    var adminId: String = ""
    var mute: Bool = false
    var notification: Bool = true
    var photo: String = ""
    var saveMedia: Bool = true
    var title: String = ""
    var subject: String = ""
}

extension Chat: Equatable {
    static func ==(lhs: Chat, rhs: Chat) -> Bool {
        return lhs.dialogID == rhs.dialogID
    }
}

class ChatsViewController: UIViewController {

    @IBOutlet weak var chatsTableView: UITableView!
    
    fileprivate var databaseRef: DatabaseReference!
    
    fileprivate var chats: [Chat] = [] {
        didSet {
            chats = chats.sorted(by: {$0.0.lastMessageDateSent > $0.1.lastMessageDateSent})
            chatsTableView.reloadData()
        }
    }
    
    fileprivate var filteredChats: [Chat] = [] {
        didSet {
            chatsTableView.reloadData()
        }
    }
    fileprivate var isFilterOn: Bool = false
    
    var unreadMessagesNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chats"
        chatsTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        chatsTableView.tableFooterView = UIView()
        
        databaseRef = Database.database().reference()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.shared.getConnectionStatus(block: { status in
            if status {
                self.unreadMessagesNumber = 0
                self.getAllUserChats()
            } else {
                SVProgressHUD.showInfo(withStatus: "You can't connect the Firebase Service. Please try again later.")
            }
        })
    }
    
    private func updateBadgeValue(to number: Int) {
        if let tabItems = self.tabBarController?.tabBar.items {
            unreadMessagesNumber += number
            tabItems[0].badgeValue = unreadMessagesNumber > 0 ? unreadMessagesNumber.description : nil
        }
    }
    
    private func getUnreadMessagesNumber(_ lastMessageDateSent: Double, _ lastSeenDate: Double) -> Int {
        return lastSeenDate < lastMessageDateSent ? 1 : 0
    }
    
    private func getAllUserChats() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading chats...")
        
        databaseRef.child("users").child(userID).child("dialogs").observe(.value, with: { chatListJSON in
            SVProgressHUD.dismiss()
            guard let chatsDict = chatListJSON.value as? NSDictionary else { return }
            
            for (key, chat) in chatsDict {
                if let chatJSON = chat as? NSDictionary {
                    
                    var chat = Chat()
                    
                    if let dialogID            = chatJSON.value(forKey: "dialogID")            as? String   { chat.dialogID = dialogID }
                    if let lastMessage         = chatJSON.value(forKey: "lastMessage")         as? String   { chat.lastMessage = lastMessage }
                    if let lastMessageDateSent = chatJSON.value(forKey: "lastMessageDateSent") as? Double   { chat.lastMessageDateSent = lastMessageDateSent }
                    if let lastMessageType     = chatJSON.value(forKey: "lastMessageType")     as? String   { chat.lastMessageType = lastMessageType }
                    if let lastSeenDate        = chatJSON.value(forKey: "lastSeenDate")        as? Double   { chat.lastSeenDate = lastSeenDate }
                    if let occupantsIds        = chatJSON.value(forKey: "occupantsIds")        as? [String] { chat.occupantsIds = occupantsIds }
                    if let type                = chatJSON.value(forKey: "type")                as? String   { chat.type = type }
                    
                    // check unread messages
                    chat.unreadedMessages += self.getUnreadMessagesNumber(chat.lastMessageDateSent, chat.lastSeenDate)
                    self.updateBadgeValue(to: chat.unreadedMessages)

                    if chat.type == "Group" {
                        if let adminId      = chatJSON.value(forKey: "adminId")      as? String { chat.adminId = adminId }
                        if let mute         = chatJSON.value(forKey: "mute")         as? Bool   { chat.mute = mute }
                        if let notification = chatJSON.value(forKey: "notification") as? Bool   { chat.notification = notification }
                        if let photo        = chatJSON.value(forKey: "photo")        as? String { chat.photo = photo }
                        if let saveMedia    = chatJSON.value(forKey: "saveMedia")    as? Bool   { chat.saveMedia = saveMedia }
                        if let title        = chatJSON.value(forKey: "title")        as? String { chat.title = title }
                        if let subject      = chatJSON.value(forKey: "subject")      as? String { chat.subject = subject }
                        
                        if self.chats.contains(chat) {
                            if let index = self.chats.index(of: chat) {
                                self.chats[index] = chat
                            }
                        } else {
                            self.chats.append(chat)
                        }
                    } else {
                        if chat.occupantsIds == nil || chat.occupantsIds.count == 0 {
                            let keyStr = key as! String
                            let index = keyStr.index(keyStr.startIndex, offsetBy: 11)
                            let dialogID = keyStr.substring(from: index)
                            chat.occupantsIds.append(dialogID)
                        }
                        if chat.occupantsIds.count > 0 {
                            FirebaseManager.shared.getUserByID(id: chat.occupantsIds.first!) { user in
                                if let username       = user.username { chat.title = username }
                                if let friendPhotoURL = user.photo    { chat.photo = friendPhotoURL }
                                
                                if self.chats.contains(chat) {
                                    if let index = self.chats.index(of: chat) {
                                        self.chats[index] = chat
                                    }
                                } else {
                                    self.chats.append(chat)
                                }
                            }
                        }
                        
                    }
                }
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "EditChatsViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"EditChatsViewController") as! EditChatsViewController
        viewController.chats = self.chats
        self.present(viewController, animated: true)
    }
    
    @IBAction func createGroupChatButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "SelectGroupChatMembersViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SelectGroupChatMembersViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ChatsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if searchText.isEmpty {
            isFilterOn = false
            self.chatsTableView.reloadData()
        } else {
            isFilterOn = true
            filteredChats = chats.filter({$0.title.contains(searchText)})
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

import Kingfisher

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilterOn ? filteredChats.count : chats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatTableViewCell.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        let chat = isFilterOn ? filteredChats[indexPath.row] : chats[indexPath.row]
        
        cell.friendLastMessageLabel.text = chat.lastMessage
        cell.friendNameLabel.text = chat.title
        
        let date = Date(timeIntervalSince1970: chat.lastMessageDateSent)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dataString = formatter.string(from: date)
        cell.lastMessageSendTime.text = dataString
        
        if !chat.photo.isEmpty {
            let url = URL(string: chat.photo)
            cell.friendPhotoImageView.kf.indicatorType = .activity
            cell.friendPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        if chat.unreadedMessages > 0 {
            cell.unreadMessagesView.isHidden = false
            cell.unreadMessagesLabel.text = chat.unreadedMessages.description
        } else {
            cell.unreadMessagesView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if chats[indexPath.row].type == "Group" {
            let storyboard = UIStoryboard(name: "GroupChatViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"GroupChatViewController") as! GroupChatViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.chat = chats[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"ChatViewController") as! ChatViewController
        
        let chat = isFilterOn ? filteredChats[indexPath.row] : chats[indexPath.row]
        
        viewController.friendID = chat.occupantsIds.first
        viewController.friendNameLabel.text = chat.title
        viewController.friendPhotoURL = chat.photo
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
