//
//  ContactsViewController.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Kingfisher

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    
    var english = "abcdefghijklmnopqrstuvwxyz".uppercased()
    
    var forwardMessage: FBMessage?
    
    let firebaseManager = FirebaseManager.shared
    
    fileprivate var friends: [User] = []
    
    fileprivate var tableData: [User] = [] {
        didSet {
            self.navigationItem.title = "Contacts(\(tableData.count))"
        }
    }
    
    fileprivate var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(getAllFriends), name: NSNotification.Name(rawValue: "updated_friends"), object: nil)
        contactsTableView.register(UINib(nibName: "ContactUserTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactUserTableViewCell")
        
        contactsTableView.sectionIndexColor = .lightGray
        contactsTableView.sectionIndexBackgroundColor = .clear
                
        contactsTableView.tableFooterView = UIView()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.getConnectionStatus(block: {status in
            if status {
                self.getAllFriends()
                ContactUtil.shared.syncContacts { (response) in
                    print("SyncContacts: \(response)")
                }
            } else {
                SVProgressHUD.showInfo(withStatus: "You can't connect the Firebase Service. Please try again later.")
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updated_friends"), object: nil)
    }
    
    @objc private func getAllFriends() {
        SVProgressHUD.show()
        FirebaseManager.shared.getUserFriends { (friends) in
            SVProgressHUD.dismiss()
            self.friends = friends
            self.reloadTableView()
        }
    }
    
    func reloadTableView() {
        tableData.removeAll()
        for user in friends {
            if searchText.isEmpty {
                tableData.append(user)
            } else {
                if user.username?.lowercased().range(of: searchText) != nil {
                    tableData.append(user)
                }
            }
            
        }
        contactsTableView.reloadData()
    }
    
    @IBAction func startGroupChatButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SelectGroupChatMembersViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SelectGroupChatMembersViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.searchText = searchText.lowercased()
        self.reloadTableView()
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return english.characters.map{String($0)}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactUserTableViewCell.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactUserTableViewCell", for: indexPath) as! ContactUserTableViewCell
        
        let friend = tableData[indexPath.row]
        cell.contactNameLabel.text = friend.username ?? ""
        
        let date = Date(timeIntervalSince1970: friend.lastSeen ?? Date().timeIntervalSinceNow)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma 'on' MMM dd, yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dataString = formatter.string(from: date)
        cell.lastSeenLabel.text = "Last seen " + dataString
        
        if let photo = friend.photo, !photo.isEmpty {
            let url = URL(string: photo)!
            cell.contactPhotoImageView.kf.indicatorType = .activity
            cell.contactPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let forwardMessage = forwardMessage {
            let alertController = UIAlertController(title: "\nShare with \(tableData[indexPath.row].username!)?\n\n", message: nil, preferredStyle: .alert)
            alertController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            alertController.addAction(cancelAction)
            
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("Yes")
                FirebaseManager.shared.sendMessage(message: forwardMessage.messageText, type: forwardMessage.type, toFriend: self.tableData[indexPath.row])
                let alertController = UIAlertController(title: "\nYour message has been received!\n\n", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            alertController.addAction(yesAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"ChatViewController") as! ChatViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.friendID = tableData[indexPath.row].id
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

