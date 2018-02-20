//
//  GroupChatMemberTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 04.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class GroupChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let view = UIView()
        view.backgroundColor = .clear
        selectedBackgroundView = view
        tintColor = Constants.UI.barColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
