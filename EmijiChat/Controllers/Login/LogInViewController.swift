//
//  LogInViewController.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class LogInViewController: UIViewController, CountryReceiveData {

    @IBOutlet weak var selectedCountryButton: UIButton!
    @IBOutlet weak var countryPhoneCodeLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var numberPhoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberPhoneTextField.addTarget(self, action: #selector(numberPhoneDidChange(_:)), for: .editingChanged)
        let countryUtils = CountryUtils.shared
        if let countryInfo = countryUtils.getCurrentCountryInfo() {
            countryPhoneCodeLabel.text = countryInfo.code
            selectedCountryButton.setTitle(countryInfo.name, for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        numberPhoneTextField.becomeFirstResponder()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
//        numberPhoneTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        // TODO: forgot password implementation
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        guard
            let countryPhoneCode = countryPhoneCodeLabel.text,
            let numberPhoneText = numberPhoneTextField.text else { return }
        
        let phoneNumber = countryPhoneCode.removingWhitespaces() + numberPhoneText.removingWhitespaces()
        
        let alertController = UIAlertController(title: "Mobile Number Confirmation", message: "We will send a verification code to the following number: \(phoneNumber)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
            self.sendSMS(to: phoneNumber)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    private func sendSMS(to phoneNumber: String) {
        self.view.endEditing(true)

        SVProgressHUD.show()
        
        let phoneNumber = self.countryPhoneCodeLabel.text!.removingWhitespaces() + self.numberPhoneTextField.text!.removingWhitespaces()
        print(phoneNumber)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // Display enter verification code view controller
            print("All OK")
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            SVProgressHUD.dismiss()
            
            let storyboard = UIStoryboard(name: "VerificationCodeViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"VerificationCodeViewController") as! VerificationCodeViewController
            viewController.phoneNumber = phoneNumber
            self.navigationController?.pushViewController(viewController, animated: true)
        }
 
    }
    
    func numberPhoneDidChange(_ sender: UITextField) {
        if let phoneLength = sender.text?.characters.count {
            if phoneLength > 0 {
                logInButton.isEnabled = true
            } else {
                logInButton.isEnabled = false
            }
        }
    }
    
    func pass(countryName: String, countryPhoneCode: String) {
        print(countryName)
        print(countryPhoneCode)
        selectedCountryButton.setTitle(countryName, for: .normal)
        selectedCountryButton.setNeedsLayout()
        countryPhoneCodeLabel.text = countryPhoneCode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCountries" {
            if let nextScene = segue.destination as? CountriesListViewController {
                nextScene.delegate = self
            }
        }
    }
}
