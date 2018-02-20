//
//  BlockedUserTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 28.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    var unblockButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func unblockButtonTapped(_ sender: UIButton) {
        unblockButtonTapped?()
    }

}
