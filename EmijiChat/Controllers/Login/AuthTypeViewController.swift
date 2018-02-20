//
//  AuthTypeViewController.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class AuthTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "LogInViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()//(withIdentifier :"VerificationCodeViewController") as! VerificationCodeViewController
        self.present(viewController!, animated: true)
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SignUpViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()//(withIdentifier :"VerificationCodeViewController") as! VerificationCodeViewController
        self.present(viewController!, animated: true)
    }
}
