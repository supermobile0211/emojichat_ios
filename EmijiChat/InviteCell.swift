//
//  InviteCell.swift
//  EmijiChat
//
//  Created by Star on 10/14/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    static let defaultRowHeight: CGFloat = 70
    
    var user: User? {
        didSet {
            if let user = user {
                nameLabel.text = user.username ?? ""
                phoneNumberLabel.text = user.phoneNumber ?? ""
                
                if AppUtils.shared.isSelectedContact(user) {
                    checkImageView.image = UIImage(named: "checked")
                } else {
                    checkImageView.image = UIImage(named: "unchecked")
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let view = UIView()
        view.backgroundColor = .clear
        selectedBackgroundView = view
        tintColor = Constants.UI.barColor
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
