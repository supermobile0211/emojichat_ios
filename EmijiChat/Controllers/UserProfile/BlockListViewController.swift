//
//  BlockListViewController.swift
//  EmijiChat
//
//  Created by Bender on 28.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Kingfisher

class BlockListViewController: UIViewController {

    @IBOutlet weak var blockedUsersTableView: UITableView!
    
    fileprivate var blockedUsers: [User] = [] {
        didSet {
            blockedUsersTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseManager.shared.getBlockedUsers(block: { blockedUsers in
            self.blockedUsers = blockedUsers ?? []
        })
    }
}

extension BlockListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath) as! BlockedUserTableViewCell
        
        let blockedUser = blockedUsers[indexPath.row]
        
        if let username = blockedUser.username {
            cell.userNameLabel.text = username
        }
        
        if let photo = blockedUser.photo {
            if !photo.isEmpty {
                let url = URL(string: photo)
                cell.avatarImageView.kf.indicatorType = .activity
                cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        cell.unblockButtonTapped = {
            let alertController = UIAlertController(title: "\nAre you sure you\n want to unblock this person?\n\n", message: nil, preferredStyle: .alert)
            alertController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("Yes")
                if let id = blockedUser.id {
                    FirebaseManager.shared.unblockUser(with: id)
                    if let index = self.blockedUsers.index(of: blockedUser) {
                        self.blockedUsers.remove(at: index)
                    }
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
