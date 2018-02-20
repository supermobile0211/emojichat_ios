//
//  SelectGroupChatMembersViewController.swift
//  EmijiChat
//
//  Created by Bender on 04.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import SVProgressHUD

class SelectGroupChatMembersViewController: UIViewController {

    @IBOutlet weak var groupChatSearchBar: UISearchBar!
    
    @IBOutlet weak var selectedFriendsNumberLabel: UILabel!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    
    fileprivate var friends: [User] = [] {
        didSet {
            friendsTableView.reloadData()
        }
    }
    
    fileprivate var selectedFriends: [User] = [] {
        didSet {
            selectedFriendsCollectionView.reloadData()
            selectedFriendsNumberLabel.text = selectedFriends.count.description + " Friends Selected"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.tableFooterView = UIView()
        
        let firebaseManager = FirebaseManager.shared
        firebaseManager.getConnectionStatus { (status) in
            if status {
                SVProgressHUD.show()
                firebaseManager.getUserFriends { friends in
                    SVProgressHUD.dismiss()
                    self.friends = friends
                }
            } else {
                SVProgressHUD.showInfo(withStatus: "You can't connect the Firebase Service. Please try again later.")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        let submitButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .plain, target: self, action: #selector(submitButtonTapped))
        self.navigationItem.rightBarButtonItem = submitButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        friendsTableView.setEditing(true, animated: true)
    }
    
    func submitButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "NewGroupViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"NewGroupViewController") as! NewGroupViewController
        viewController.selectedFriends = selectedFriends
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func closeButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

import Kingfisher

extension SelectGroupChatMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatMemberTableViewCell", for: indexPath) as? GroupChatMemberTableViewCell else {
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

extension SelectGroupChatMembersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupChatMemberCollectionViewCell", for: indexPath) as? GroupChatMemberCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let friendName = selectedFriends[indexPath.row].username {
            cell.userNameLabel.text = friendName
        }
        
        if let photo = selectedFriends[indexPath.row].photo {
            if !photo.isEmpty {
                let url = URL(string: photo)
                cell.userPhotoImageView.kf.indicatorType = .activity
                cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        cell.removeUserButtonTapped = {
            if let row = self.friends.index(of: self.selectedFriends[indexPath.row]) {
                self.friendsTableView.deselectRow(at: IndexPath(row: row, section: 0), animated: true)
                self.selectedFriends.remove(at: indexPath.row)
            }
        }
        
        return cell
    }
}
