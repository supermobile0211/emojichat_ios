//
//  UserProfileViewController.swift
//  EmijiChat
//
//  Created by Bender on 28.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import MobileCoreServices
import Kingfisher

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    
    fileprivate var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changePhotoButton.sizeToFit()
        changePhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        
        if let userAvatarURL = UserDefaults.standard.string(forKey: "avatarDownloadURL") {
            if !userAvatarURL.isEmpty {
                let url = URL(string: userAvatarURL)
                self.userPhotoImageView.kf.indicatorType = .activity
                self.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            userNameLabel.text = username
        }
        
        if let mobileNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") {
            userPhoneNumberLabel.text = mobileNumber
        }
    }
    
    @IBAction func showBlockListButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "BlockListViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"BlockListViewController") as! BlockListViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func changePhotoButtonTapped(_ sender: UIButton) {
        
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

extension UserProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error while take photo")
            return
        }
        
        FirebaseManager.shared.changeUserPhoto(with: image, block: { photoURL in
            if let photo = photoURL {
                if !photo.isEmpty {
                    let url = URL(string: photo)
                    self.userPhotoImageView.kf.indicatorType = .activity
                    self.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                }
            }
        })
    }
}
