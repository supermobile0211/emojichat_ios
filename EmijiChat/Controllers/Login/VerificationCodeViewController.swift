//
//  VerificationCodeViewController.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth

class VerificationCodeViewController: UIViewController {

    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verificationCodeTextField.becomeFirstResponder()
        phoneNumberButton.setTitle(phoneNumber, for: .normal)
        phoneNumberButton.setNeedsLayout()
    }
    
    @IBAction func verificationCodeChangeg(_ sender: UITextField) {
        if let verificationCodeLength = sender.text?.characters.count {
            if verificationCodeLength > 5 {
                submitButton.isEnabled = true
            } else {
                submitButton.isEnabled = false
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        SVProgressHUD.show(withStatus: "Verifying...")
        
        SVProgressHUD.setMinimumDismissTimeInterval(1)

        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCodeTextField.text!)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            // User is signed in
            // Display complete profile controller
            
            let token = Messaging.messaging().fcmToken
            let prefs = UserDefaults.standard
            prefs.set(token, forKey: "pushToken")
            prefs.set(self.phoneNumber, forKey: "userPhoneNumber")
            prefs.set(user?.uid, forKey: "userID")
            prefs.set(verificationID, forKey: "authVerificationID")
            prefs.set(false, forKey: "contact_loaded")
            prefs.synchronize()
            
            SVProgressHUD.showSuccess(withStatus: "Verified")
            
            if let userName = user?.displayName {
                prefs.set(userName, forKey: "username")
                prefs.synchronize()
                let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier :"MainTabBar")
                self.present(viewController, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "CompleteProfileViewController", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier :"CompleteProfileViewController") as! CompleteProfileViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            
            
        }
    }
    
    @IBAction func didntReceiveCodeButtonTapped(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Resend", style: .default) { action -> Void in
            print("Resend tapped")
            
            guard let phoneNumber = self.phoneNumber else {
                return
            }
            
            SVProgressHUD.show()
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                // Display enter verification code view controller
                print("All OK")
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                /*
                 let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                 */
                SVProgressHUD.dismiss()
            }
        }
        actionSheetController.addAction(saveActionButton)

        self.present(actionSheetController, animated: true, completion: nil)
    }
}
