//
//  AddNewGroupParcipiantsViewController.swift
//  EmijiChat
//
//  Created by Bender on 05.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddNewGroupParcipiantsViewController: UIViewController {

    @IBOutlet weak var friendsTableView: UITableView!
    
    fileprivate var friends: [User] = [] {
        didSet {
            friendsTableView.reloadData()
        }
    }
    
    var groupID: String?
    
    var groupParcipiants: [String]?
    
    fileprivate var selectedFriends: [User] = [] {
        didSet {
            navigationItem.title = "Selected(" + selectedFriends.count.description + ")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.tableFooterView = UIView()
        
        SVProgressHUD.show()
        FirebaseManager.shared.getUserFriends { friends in
            SVProgressHUD.dismiss()
            var noFriendsArr: [User] = friends
            
            if let groupParcipiants = self.groupParcipiants {
                for groupMember in groupParcipiants {
                    if let index = noFriendsArr.index(where: {$0.id == groupMember}) {
                        noFriendsArr.remove(at: index)
                    }
                }
                self.friends = noFriendsArr
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        friendsTableView.setEditing(true, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let groupID = groupID, selectedFriends.count > 0, let groupParcipiants = groupParcipiants {
            FirebaseManager.shared.addNewGroupMembers(groupID: groupID, newMembersIDs: selectedFriends.map{$0.id!} + groupParcipiants)
        }
        dismiss(animated: true, completion: nil)
    }
}

import Kingfisher

extension AddNewGroupParcipiantsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewGroupParcipiantsTableViewCell", for: indexPath) as? AddNewGroupParcipiantsTableViewCell else {
            return UITableViewCell()
        }
        
        if let friendName = friends[indexPath.row].username {
            cell.userNameLabel.text = friendName
        }
        
        if let photo = friends[indexPath.row].photo {
            if !photo.isEmpty {
                let url = URL(string: photo)
                cell.userPhotoImageView.kf.indicatorType = .activity
                cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriends.append(friends[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedFriends.index(of: friends[indexPath.row]) {
            selectedFriends.remove(at: index)
        }
    }
}
