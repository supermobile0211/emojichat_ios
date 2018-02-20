//
//  SearchResultsViewController.swift
//  EmijiChat
//
//  Created by Bender on 02.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SearchResultsViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchText: String = ""
    
    fileprivate var users: [User] = []
    
    fileprivate lazy var rootRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.text = searchText
        FirebaseManager.shared.getConnectionStatus { status in
            if status {
                self.searchUser()
            } else {
                SVProgressHUD.showInfo(withStatus: "You can't connect the Firebase Service. Please try again later.")
            }
        }
        
    }
    
    fileprivate func searchUser() {
        SVProgressHUD.show(withStatus: "Searching...")
        
        rootRef.child("users").queryOrdered(byChild: "username").queryStarting(atValue: searchBar.text!).queryEnding(atValue: searchBar.text!+"\u{f8ff}").observe(.value, with: { snapshot in
            SVProgressHUD.dismiss()
            
            self.users = User().map(snapshot.value)
            print(self.users)
            self.searchResultsTableView.reloadData()
        })
    }
}

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchUser()
    }
}

import Kingfisher

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindedUserTableViewCell", for: indexPath) as! FindedUserTableViewCell
        let user = users[indexPath.row]
        
        cell.user = user
        cell.userFirstNameLabel.text = user.firstname
        cell.userLastNameLabel.text = user.lastname
        if !(user.photo?.isEmpty)! {
            let url = URL(string: user.photo!)!
            cell.userAvatarImageView.kf.indicatorType = .activity
            cell.userAvatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        return cell
    }
}
