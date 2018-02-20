//
//  SwitchTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    static let defaultRowHeight: CGFloat = 60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var switchButtonToggle : (() -> Void)? = nil
    
    @IBAction func switchButtonToggle(_ sender: UISwitch) {
        switchButtonToggle?()
    }
}
