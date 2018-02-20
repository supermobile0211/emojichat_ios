//
//  TermsPrivacyViewController.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class TermsPrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AuthTypeViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! AuthTypeViewController
//        self.present(viewController, animated: true)
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(viewController, animated: false, completion: nil)
        
    }
    
    @IBAction func showTermsButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "http://www.MuslimEmoji.com/Terms") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func showPrivacyPolicyButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "http://www.MuslimEmoji.com/PrivacyPolicy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
