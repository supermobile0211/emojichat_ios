//
//  EditChatsViewController.swift
//  EmijiChat
//
//  Created by Bender on 04.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class EditChatsViewController: UIViewController {

    @IBOutlet weak var chatsTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var chats: [Chat] = []
    
    fileprivate var selectedChats: [Chat] = [] {
        didSet {
            deleteButton.isEnabled = selectedChats.count > 0 ? true : false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatsTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        chatsTableView.tableFooterView = UIView()
        chatsTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        chatsTableView.setEditing(!chatsTableView.isEditing, animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Deleted chats\ncan't be recovered.\nAre you sure\nyou want to continue?\n", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            for chat in self.selectedChats {
                if let index = self.chats.index(of: chat) {
                    self.chats.remove(at: index)
                }
                FirebaseManager.shared.deleteChat(with: chat.dialogID)
            }
            self.selectedChats = []
            self.chatsTableView.reloadData()
        }
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

import Kingfisher

extension EditChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatTableViewCell.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        let chat = chats[indexPath.row]
        
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
        selectedChats.append(chats[indexPath.row])
        deleteButton.setTitle("Delete (\(selectedChats.count))", for: .normal)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedChats.index(of: chats[indexPath.row]) {
            selectedChats.remove(at: index)
            deleteButton.setTitle("Delete (\(selectedChats.count))", for: .normal)
        }
    }
}
