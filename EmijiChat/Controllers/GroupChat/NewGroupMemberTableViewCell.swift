//
//  NewGroupMemberTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 05.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class NewGroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var removeUserButtonTapped : (() -> Void)? = nil
    @IBAction func removeUserButtonTapped(_ sender: UIButton) {
        removeUserButtonTapped?()
    }
}
