//
//  FriendProfileViewController.swift
//  EmijiChat
//
//  Created by Bender on 30.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Kingfisher

class FriendProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mNumberLabel: UILabel!
    
    var friendPhotoURL: String?
    var friendName: String?
    var friendMobilePhone: String?
    var friendID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let photo = friendPhotoURL {
            if !photo.isEmpty {
                let url = URL(string: photo)
                avatarImageView.kf.indicatorType = .activity
                avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        if let friendName = friendName {
            nameLabel.text = friendName
        }
        
        if let friendMobilePhone = friendMobilePhone {
            mNumberLabel.text = friendMobilePhone
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidesBottomBarWhenPushed = true
    }
    
    @IBAction func notificationsSwitchValueChanged(_ sender: UISwitch) {
        if let friendID = friendID {
            FirebaseManager.shared.changeNotificationValue(to: sender.isOn, for: friendID)
        }
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"CallViewController") as! CallViewController
        UIApplication.shared.statusBarView?.backgroundColor = .clear//Constants.UI.barColor
        self.present(viewController, animated: true)
    }
    
    @IBAction func videoCallButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VideoCallViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"VideoCallViewController") as! VideoCallViewController
        UIApplication.shared.statusBarView?.backgroundColor = .clear//Constants.UI.barColor
        self.present(viewController, animated: true)
    }
    
    @IBAction func blockUserButtonTapped(_ sender: UIButton) {
        if let friendID = friendID {
            FirebaseManager.shared.blockUser(with: friendID)
        }
    }
}
