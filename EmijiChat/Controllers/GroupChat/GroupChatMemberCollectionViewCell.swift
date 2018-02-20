//
//  GroupChatMemberCollectionViewCell.swift
//  EmijiChat
//
//  Created by Bender on 04.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class GroupChatMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var removeUserButtonTapped : (() -> Void)? = nil
    @IBAction func removeUserButtonTapped(_ sender: UIButton) {
        removeUserButtonTapped?()
    }
}
