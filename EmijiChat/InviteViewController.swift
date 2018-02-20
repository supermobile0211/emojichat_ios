//
//  InviteViewController.swift
//  EmijiChat
//
//  Created by Star on 10/14/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import MessageUI

class InviteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var selectedLabel: UILabel!
    
    fileprivate var contacts: [User] = []
    fileprivate var tableData: [User] = []
    fileprivate var searchText = ""
    
    var english = "abcdefghijklmnopqrstuvwxyz".uppercased()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Invite"
        AppUtils.shared.workingUsers.removeAll()
        
        tableView.sectionIndexColor = .lightGray
        tableView.sectionIndexBackgroundColor = .clear
        
        ContactUtil.shared.makeContactInfoWithoutFriends(friends: FirebaseManager.shared.friends)
        contacts = ContactUtil.shared.contactBookInfoWithoutFriends
        tableData = ContactUtil.shared.contactBookInfoWithoutFriends
        
        tableView.reloadData()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func inviteButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Invite Friends", message: "You may be charged by your carrer for this text message. The recipient must be able to receive a message in order for the invitation to be delivered", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { action in
            alertController.dismiss(animated: true, completion: nil)
            if MFMessageComposeViewController.canSendText() {
                let controller = MFMessageComposeViewController()
                controller.body = "I am using Muslim Emoji Chat app. To chat with me for free please install the Muslim Emoji Chat on your phone at http://www.muslimemoji.com."
                controller.recipients = self.getPhoneNumbers()
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(doneAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func getPhoneNumbers() -> [String] {
        var phones: [String] = []
        if AppUtils.shared.workingUsers.count > 0 {
            for user in AppUtils.shared.workingUsers {
                if let phone = user.phoneNumber {
                    phones.append(phone)
                }
            }
        }
        return phones
    }
    
    func reloadTableView() {
        tableData.removeAll()
        for user in contacts {
            if searchText.isEmpty {
                tableData.append(user)
            } else {
                if user.username?.lowercased().range(of: searchText) != nil {
                    tableData.append(user)
                }
            }
            
        }
        tableView.reloadData()
    }
    
}

extension InviteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.lowercased()
        self.reloadTableView()
    }
}

extension InviteViewController: UITableViewDataSource, UITableViewDelegate {
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
        return InviteCell.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as! InviteCell
        
        let user = tableData[indexPath.row]
        cell.user = user
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = tableData[indexPath.row]
        if AppUtils.shared.isSelectedContact(user) {
            AppUtils.shared.removeContact(user)
        } else {
            AppUtils.shared.addContct(user)
        }
        
        self.tableView.reloadData()
        if AppUtils.shared.workingUsers.count > 0 {
            btnInvite.isEnabled = true
            selectedLabel.text = "\(AppUtils.shared.workingUsers.count) Friends Selected"
        } else {
            btnInvite.isEnabled = false
            selectedLabel.text = ""
        }
    }
    
}

extension InviteViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

