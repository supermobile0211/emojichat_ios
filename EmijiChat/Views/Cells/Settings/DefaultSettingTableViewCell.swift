//
//  DefaultSettingTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class DefaultSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let defaultRowHeight: CGFloat = 60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
