//
//  CompleteProfileViewController.swift
//  EmijiChat
//
//  Created by Bender on 26.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import SVProgressHUD
import GoogleSignIn

class CompleteProfileViewController: UIViewController {

    @IBOutlet weak var enterNameTextField: UITextField!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userAvatarCoverageImageView: UIImageView!
    @IBOutlet weak var userAvatarCameraImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    var storageRef: StorageReference!
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // load tab bar controller
        if
            let pushToken       = UserDefaults.standard.string(forKey: "pushToken"),
            let userPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber"),
            let userName        = enterNameTextField.text,
            let userID          = Auth.auth().currentUser?.uid
        {
            UserDefaults.standard.set(userName, forKey: "username")
            let userRef = databaseRef.child("users/\(userID)")
            userRef.setValue(["username": userName,
                              "pushToken": pushToken,
                              "photo": UserDefaults.standard.string(forKey: "avatarDownloadURL") ?? "",
                              "notification": true,
                              "mobile": userPhoneNumber,
                              "id": userID,
                              "lastSeen": Date().timeIntervalSince1970
                ])
            
            let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"MainTabBar")
            self.present(viewController, animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "Oops! Something went wrong.")
        }
    }
    
    @IBAction func nameTextFieldDidChange(_ sender: UITextField) {
        if let userNameLenght = sender.text?.characters.count {
            if userNameLenght > 2 {
                checkIcon.isHidden = false
                nextButton.isEnabled = true
            } else {
                checkIcon.isHidden = true
                nextButton.isEnabled = false
            }
        }
    }
    
    @IBAction func keyboardDoneButtonTapped(_ sender: UITextField) {
        self.view.endEditing(true)
    }
    
    @IBAction func loadAvatarButtonTapped(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let takePhotoActionButton = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            print("Take Photo tapped")
            
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(takePhotoActionButton)
        
        let choosePhotoActionButton = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
            print("Choose Photo tapped")
            
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            
            self.imagePicker.navigationBar.isTranslucent = false
            self.imagePicker.navigationBar.barTintColor = Constants.UI.barColor
            self.imagePicker.navigationBar.tintColor = .white
            self.imagePicker.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.white
            ]
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePhotoActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

extension CompleteProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func saveImageDocumentDirectory(image: UIImage) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("userProfileAvatarImage.jpg")
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0)
        fileManager.createFile(atPath: paths, contents: imageData, attributes: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error while take photo")
            return
        }
        
        FirebaseManager.shared.changeUserPhoto(with: image, block: {photoURL in
            print(photoURL ?? "")
        })
        
        self.view.layoutIfNeeded()
        userAvatarCoverageImageView.isHidden = true
        userAvatarCameraImageView.isHidden = true
//        userAvatarImageView.contentMode = .scaleAspectFit
        userAvatarImageView.image = image
        saveImageDocumentDirectory(image: image)
        userAvatarImageView.layer.cornerRadius = 5
        userAvatarImageView.clipsToBounds = true
    }
}
