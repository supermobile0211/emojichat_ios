//
//  ChatTableViewCell.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendPhotoImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendLastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageSendTime: UILabel!
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    @IBOutlet weak var unreadMessagesView: UIView!
    
    static let defaultRowHeight: CGFloat = 70
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let view = UIView()
        view.backgroundColor = Constants.UI.barColor.withAlphaComponent(0.4)
        selectedBackgroundView = view
        tintColor = Constants.UI.barColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
