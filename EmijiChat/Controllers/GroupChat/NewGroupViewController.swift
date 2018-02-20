//
//  NewGroupViewController.swift
//  EmijiChat
//
//  Created by Bender on 05.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import MobileCoreServices

class NewGroupViewController: UIViewController {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupParcipiantsNumberLabel: UILabel!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    fileprivate var imagePicker: UIImagePickerController!
    
    var selectedFriends: [User] = [] {
        didSet {
            guard groupMembersTableView != nil  else {
                return
            }
            groupMembersTableView.reloadData()
            groupParcipiantsNumberLabel.text = "Parcipiants: \(selectedFriends.count) of 500"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupMembersTableView.tableFooterView = UIView()
        groupSubjectTextView.textContainer.lineFragmentPadding = 0
        
        groupParcipiantsNumberLabel.text = "Parcipiants: \(selectedFriends.count) of 500"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addGroupImageButtonTapped(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelActionButton)
        
        let takePhotoActionButton = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(takePhotoActionButton)
        
        let choosePhotoActionButton = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
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
    
    @IBAction func saveGroupButtonTapped(_ sender: UIBarButtonItem) {
        FirebaseManager.shared.createGroupChat(title: groupNameTextField.text!,
                                               subject: groupSubjectTextView.text,
                                               photo: groupImageView.image,
                                               membersIDs: selectedFriends.map{$0.id!}
        ){ groupKey in
            let storyboard = UIStoryboard(name: "GroupDescribeViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"GroupDescribeViewController") as! GroupDescribeViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.groupName = self.groupNameTextField.text
            viewController.groupSubject = self.groupSubjectTextView.text
            viewController.groupImage = self.groupImageView.image
            viewController.groupParcipiants = self.selectedFriends.map{$0.id!}
            viewController.groupID = groupKey
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

import Kingfisher

extension NewGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewGroupMemberTableViewCell", for: indexPath) as? NewGroupMemberTableViewCell else {
            return UITableViewCell()
        }
        
        if let friendName = selectedFriends[indexPath.row].username {
            cell.userNameLabel.text = friendName
        }
        
        if let photo = selectedFriends[indexPath.row].photo {
            if !photo.isEmpty {
                let url = URL(string: photo)
                cell.userPhotoImageView.kf.indicatorType = .activity
                cell.userPhotoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
        
        cell.removeUserButtonTapped = {
            self.selectedFriends.remove(at: indexPath.row)
        }
        
        return cell
    }
}

extension NewGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error while take photo")
            return
        }
        groupImageView.image = image
    }
}

// UITextFieldDelegate
extension NewGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let groupSubject = groupSubjectTextView.text, let groupName = groupNameTextField.text {
            if groupSubject.isEmpty || groupName.isEmpty {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// UITextViewDelegate
extension NewGroupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Please provide a group subject and optional group icon")
        {
            textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let groupName = groupNameTextField.text {
            if groupName.isEmpty || groupSubjectTextView.text.isEmpty {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        if (textView.text == "")
        {
            textView.text = "Please provide a group subject and optional group icon"
        }
    }
}
