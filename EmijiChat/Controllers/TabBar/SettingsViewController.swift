//
//  SettingsViewController.swift
//  EmijiChat
//
//  Created by Bender on 27.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Kingfisher

class SettingsViewController: UIViewController {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    enum SettingsCells {
        case simple
        case withSwitch
        case separator
        case trademark
    }
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    let cells: [SettingsCells] = [
        .simple,
        .separator,
        .withSwitch,
        .simple,
        .simple,
        .simple,
        .simple,
        .simple,
        .trademark
    ]
    
    let cellTitles: [String] = [
        "Your Profile",
        "",
        "Notifications",
        "Muslim Emojis",
        "Privacy",
        "Contact Us",
        "Help & About Us",
        "Rate Us",
        "",
    ]
    
    let cellImages: [String] = [
        "settings_profile",
        "",
        "notification",
        "emoji_tab",
        "privacy",
        "email",
        "help",
        "rateUs",
        "",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsTableView.register(UINib(nibName: "DefaultSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultSettingTableViewCell")
        settingsTableView.register(UINib(nibName: "BlueSeparatorTableViewCell", bundle: nil), forCellReuseIdentifier: "BlueSeparatorTableViewCell")
        settingsTableView.register(UINib(nibName: "TrademarkTableViewCell", bundle: nil), forCellReuseIdentifier: "TrademarkTableViewCell")
        settingsTableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
        
        
        if let userAvatarURL = UserDefaults.standard.string(forKey: "avatarDownloadURL") {
            if !userAvatarURL.isEmpty {
                let url = URL(string: userAvatarURL)
                self.userAvatarImageView.kf.indicatorType = .activity
                self.userAvatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            userNameLabel.text = username
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count//cellsOrder.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch cells[indexPath.section] {
        case .simple:
            return DefaultSettingTableViewCell.defaultRowHeight
        case .withSwitch:
            return SwitchTableViewCell.defaultRowHeight
        case .separator:
            return 30
        case .trademark:
            return TrademarkTableViewCell.defaultRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.section] {
        case .simple:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultSettingTableViewCell", for: indexPath) as! DefaultSettingTableViewCell
            
            cell.descriptionLabel.text = cellTitles[indexPath.section]
            cell.leftIconImageView.image = UIImage(named: cellImages[indexPath.section])
            
            return cell
        case .withSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            
            cell.descriptionLabel.text = cellTitles[indexPath.section]
            cell.leftIconImageView.image = UIImage(named: cellImages[indexPath.section])
            
            cell.switchButtonToggle = {
                FirebaseManager.shared.changeNotificationValue(to: cell.switchButton.isOn)
            }
            
            return cell
        case .separator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlueSeparatorTableViewCell", for: indexPath) as! BlueSeparatorTableViewCell
            
            return cell
        case .trademark:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrademarkTableViewCell", for: indexPath) as! TrademarkTableViewCell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "UserProfileViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"UserProfileViewController") as! UserProfileViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 3 {
            // Muslim Emoji
            
        } else if indexPath.section == 4 {
            // Privacy
            guard let url = URL(string: "http://www.muslimemoji.com/privacy") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else if indexPath.section == 5 {
            // Contact Us
            let storyboard = UIStoryboard(name: "ContactUs", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 6 {
            // Help & About us
            guard let url = URL(string: "http://www.muslimemoji.com/about") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else if indexPath.section == 7 {
            // Rate Us
        }
    }
}
