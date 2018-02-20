//
//  ContactUsViewController.swift
//  EmijiChat
//
//  Created by Star on 10/14/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            
            controller.setToRecipients(["Contact@MuslimEmoji.com"])
            controller.setSubject("Contact Us")
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}

extension ContactUsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
