//
//  EditGroupTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 06.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class EditGroupTableViewCell: UITableViewCell {

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
    
    var deleteUserButtonTapped : (() -> Void)? = nil
    @IBAction func deleteUserButtonTapped(_ sender: UIButton) {
        deleteUserButtonTapped?()
    }

}
