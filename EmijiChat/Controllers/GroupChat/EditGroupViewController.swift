//
//  EditGroupViewController.swift
//  EmijiChat
//
//  Created by Bender on 06.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class EditGroupViewController: UIViewController {

    @IBOutlet weak var parcipiantsTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var groupPhotoImageView: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var parcipiantsLabel: UILabel!
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var saveMediaSwitch: UISwitch!
    
    var parcipiants: [User] = [] {
        didSet {
            if parcipiantsTableView != nil {
                parcipiantsLabel.text = "Parcipiants: \(parcipiants.count) of 500"
                parcipiantsTableView.reloadData()
            }
        }
    }
    
    var group: Chat?
    var groupImage: UIImage?
    fileprivate var groupChanged: Chat? = Chat()
    
    var groupID: String?
    
    fileprivate var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupChanged = group
        
        saveButton.isEnabled = true
        
        parcipiantsTableView.tableFooterView = UIView()
        
        parcipiantsLabel.text = "Parcipiants: \(parcipiants.count) of 500"
        
        if let groupImage = groupImage {
            groupPhotoImageView.image = groupImage
        }
        
        if let mute = group?.mute {
            muteSwitch.isOn = mute
        }
        
        if let saveMedia = group?.saveMedia {
            saveMediaSwitch.isOn = saveMedia
        }
        
        if let groupName = group?.title {
            groupNameTextField.text = groupName
        }
        
        if let groupSubject = group?.subject {
            groupSubjectTextField.text = groupSubject
        }
    }
    
    @IBAction func groupNameTextFieldDidChanged(_ sender: UITextField) {
        groupChanged?.title = sender.text!
    }
    
    @IBAction func groupSubjectFieldDidChanged(_ sender: UITextField) {
        groupChanged?.subject = sender.text!
    }
    
    @IBAction func muteValueChanged(_ sender: UISwitch) {
        groupChanged?.mute = sender.isOn
    }
    
    @IBAction func saveMediaToCameraRollValueChanged(_ sender: UISwitch) {
        groupChanged?.saveMedia = sender.isOn
    }
    
    @IBAction func deleteGroupButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Deleting a group will remove you from the group chat", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Constants.UI.barColor
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            if let group = self.group {
                FirebaseManager.shared.deleteGroup(group: group)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let group = group, let changedGroup = groupChanged {
            FirebaseManager.shared.updateGroupChat(originalGroup: group, changedGroup: changedGroup, newGroupPhoto: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changeGroupPhotoButtonTapped(_ sender: UIButton) {
        let sheet = MyUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            // Open camera
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        sheet.addAction(cameraAction)
        
        let photoVideoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            // Open photo library
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String/*, kUTTypeMovie as String*/]
            
            self.imagePicker.navigationBar.isTranslucent = false
            self.imagePicker.navigationBar.barTintColor = Constants.UI.barColor
            self.imagePicker.navigationBar.tintColor = .white
            self.imagePicker.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.white
            ]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        sheet.addAction(photoVideoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
}

import Kingfisher

extension EditGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parcipiants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditGroupTableViewCell", for: indexPath) as? EditGroupTableViewCell else {
            return UITableViewCell()
        }
        
        if let parcipiantName = parcipiants[indexPath.row].username {
            cell.userNameLabel.text = parcipiantName
        }
        
        if let photo = parcipiants[indexPath.row].photo {
            if !photo.isEmpty {
                let url = URL(string: photo)
                cell.userPhotoImageView.kf.indicatorType = .activity
                cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
 
        cell.deleteUserButtonTapped = {
            if let group = self.group {
                FirebaseManager.shared.deleteUserFromGroup(group: group, userID: self.parcipiants[indexPath.row].id!)
                self.parcipiants.remove(at: indexPath.row)
            }
        }
        
        return cell
    }
}

import MobileCoreServices

extension EditGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let group = group, let changedGroup = groupChanged {
                FirebaseManager.shared.updateGroupChat(originalGroup: group, changedGroup: changedGroup, newGroupPhoto: image)
            }
        } else {
            print("Error while take photo/video")
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
