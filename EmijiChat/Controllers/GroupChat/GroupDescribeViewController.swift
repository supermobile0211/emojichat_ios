//
//  GroupDescribeViewController.swift
//  EmijiChat
//
//  Created by Bender on 05.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class GroupDescribeViewController: UIViewController {
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var groupSubjectLabel: UILabel!
    @IBOutlet weak var groupParcipiantsNumberLabel: UILabel!
    
    var groupName: String?
    var groupSubject: String?
    var groupImage: UIImage?
    var groupParcipiants: [String]?
    fileprivate var groupUsers: [User]? = []
    var groupID: String?
    var group: Chat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTableView.tableFooterView = UIView()
        
        if let groupName = groupName {
            groupNameLabel.text = groupName
        }
        if let groupSubject = groupSubject {
            groupSubjectLabel.text = groupSubject
        }
        if let groupImage = groupImage {
            groupImageView.image = groupImage
        }
        
        if let groupParcipiants = groupParcipiants {
            for groupMemberID in groupParcipiants {
                FirebaseManager.shared.getUserByID(id: groupMemberID) { groupMember in
                    self.groupUsers?.append(groupMember)
                    if groupParcipiants.count == self.groupUsers?.count {
                        self.groupMembersTableView.reloadData()
                    }
                }
            }
            groupParcipiantsNumberLabel.text = "Parcipiants: \(groupParcipiants.count + 1) of 500"
        }
        
        if let userID = FirebaseManager.shared.getCurrentUserID() {
            editButton.isEnabled = userID == group?.adminId ? true : false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "EditGroupViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"EditGroupViewController") as! EditGroupViewController
        
        viewController.groupID = groupID
        if let group = self.group, let groupUsers = groupUsers {
            viewController.group = group
            viewController.parcipiants = groupUsers
            viewController.groupImage = groupImageView.image
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func groupNotificationValueChaneged(_ sender: UISwitch) {
        if let groupID = groupID {
            FirebaseManager.shared.changeNotificationValueForGroup(withID: groupID, newValue: sender.isOn)
        }
    }
    
    @IBAction func addParticipantsButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddNewGroupParcipiantsViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"AddNewGroupParcipiantsViewController") as! AddNewGroupParcipiantsViewController
        viewController.groupID = groupID
        viewController.groupParcipiants = groupParcipiants
        self.present(viewController, animated: true)
    }
}

extension GroupDescribeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let groupParcipiants = self.groupParcipiants else {
            return 1
        }
        return groupParcipiants.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupDescribeTableViewCell", for: indexPath) as? GroupDescribeTableViewCell else {
            return UITableViewCell()
        }
        
        // Show admin cell
        if indexPath.row == 0 {
            cell.adminMarkView.isHidden = false
            if let photo = UserDefaults.standard.string(forKey: "avatarDownloadURL") {
                    if !photo.isEmpty {
                        let url = URL(string: photo)
                        cell.userPhotoImageView.kf.indicatorType = .activity
                        cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                    }
            }
            if let username = UserDefaults.standard.string(forKey: "username") {
                cell.userNameLabel.text = username
            }
            return cell
        }
        
        if let groupUsers = groupUsers {
            if groupUsers.indices.contains(indexPath.row - 1) {
                if let photo = groupUsers[indexPath.row - 1].photo {
                    if !photo.isEmpty {
                        let url = URL(string: photo)
                        cell.userPhotoImageView.kf.indicatorType = .activity
                        cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                    }
                }
                
                if let username = groupUsers[indexPath.row - 1].username {
                    cell.userNameLabel.text = username
                }
            }
        }

        return cell
    }
}
