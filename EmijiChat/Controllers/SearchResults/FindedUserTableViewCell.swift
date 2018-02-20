//
//  FindedUserTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 02.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FindedUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userFirstNameLabel: UILabel!
    @IBOutlet weak var userLastNameLabel: UILabel!
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addUserToMyContactsButtonTapped(_ sender: UIButton) {
        if let friendID = user?.id {
            FirebaseManager.shared.addNewFriend(with: friendID)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userAvatarImageView.image = nil
        userFirstNameLabel.text = ""
        userLastNameLabel.text = ""
    }
}
