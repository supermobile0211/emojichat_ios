//
//  FirebaseManager.swift
//  EmijiChat
//
//  Created by Bender on 03.08.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation
import Firebase
import SVProgressHUD

final class FirebaseManager {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let shared = FirebaseManager()
    
    var storageRef: StorageReference = Storage.storage().reference()
    var databaseRef: DatabaseReference = Database.database().reference()
    var auth = Auth.auth()
    
    var userRef = Database.database().reference().child("users")
    var messageRef = Database.database().reference().child("messages")
    
    var friends: [User] = []
    
    func getConnectionStatus(block: @escaping (Bool) -> Swift.Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
                block(true)
            } else {
                print("Not connected")
                block(false)
            }
        })
    }
    
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    func getUserName(block: @escaping (String) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        databaseRef.child("users").child(userID).child("username").observeSingleEvent(of: .value, with: { username in
            guard let username = username.value as? String else { return }
            block(username)
            UserDefaults.standard.set(username, forKey: "username")
        })
    }
    
    func getPhoneNumber(block: @escaping (String) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        databaseRef.child("users").child(userID).child("mobile").observeSingleEvent(of: .value, with: { mobileNumber in
            guard let mobileNumber = mobileNumber.value as? String else { return }
            block(mobileNumber)
            UserDefaults.standard.set(mobileNumber, forKey: "mobileNumber")
        })
    }
    
    func getCurrentUserPhotoURL(block: @escaping (String) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        databaseRef.child("users").child(userID).child("photo").observeSingleEvent(of: .value, with: { photoURL in
            guard let photoURL = photoURL.value as? String else { return }
            block(photoURL)
        })
    }
    
    func getBlockedUsers(block: @escaping ([User]?) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        
        var blockedUsersArr: [User] = []
        
        databaseRef.child("users").child(userID).child("blockedUser").observeSingleEvent(of: .value, with: { blockedUsers in
            guard let blockedUsers = blockedUsers.value as? NSDictionary else {
                block(nil)
                return
            }
            guard let blockedUsersIDs = blockedUsers.allKeys as? [String] else {
                block(nil)
                return
            }
            
            for uid in blockedUsersIDs {
                self.getUserByID(id: uid, block: { user in
                    blockedUsersArr.append(user)
                    
                    if blockedUsersIDs.count == blockedUsersArr.count {
                        block(blockedUsersArr)
                    }
                })
            }
        })
    }
    
    func blockUser(with ID: String) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("blockedUser").child(ID).setValue(true) { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func unblockUser(with ID: String) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("blockedUser").child(ID).removeValue() { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func changeNotificationValue(to newValue: Bool) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("notification").setValue(newValue) { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func changeNotificationValue(to newValue: Bool, for friend: String) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("friends").child(friend).setValue(newValue) { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func deleteChat(with ID: String) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("dialogs").child(ID).removeValue() { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func getUserByID(id: String, block: @escaping (User) -> Swift.Void) {
        databaseRef.child("users").child(id).observeSingleEvent(of: .value, with: { userJson in
            guard let userJson = userJson.value as? NSDictionary else { return }
            
            let user = User()
            
            if let id = userJson.value(forKey: "id")                     as? String { user.id = id }
            
            if let username = userJson.value(forKey: "username")         as? String { user.username = username }
            
            if let lastname = userJson.value(forKey: "lastname")         as? String { user.lastname = lastname }
            
            if let firstname = userJson.value(forKey: "firstname")       as? String { user.firstname = firstname }
            
            if let mobile = userJson.value(forKey: "mobile")             as? String { user.phoneNumber = mobile }
            
            if let photo = userJson.value(forKey: "photo")               as? String { user.photo = photo }
            
            if let lastSeen = userJson.value(forKey: "lastSeen")         as? Double { user.lastSeen = lastSeen }
            
            if let notification = userJson.value(forKey: "notification") as? Bool   { user.notification = notification }
            
            if let pushToken = userJson.value(forKey: "pushToken")       as? String { user.pushToken = pushToken }
            
            block(user)
        })
    }
    
    func addNewFriend(with ID: String) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        databaseRef.child("users").child(userID).child("friends").child(ID).setValue(true) { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            self.databaseRef.child("users").child(ID).child("friends").child(userID).setValue(true) { error, ref in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func changeUserPhoto(with photo: UIImage, block: @escaping (String?) -> Swift.Void) {
        guard let imageData = UIImageJPEGRepresentation(photo, 0.8),
        let uid = getCurrentUserID() else { return }
        
        let avatarImagesRef = storageRef.child("images/avatars/" + uid + ".jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        SVProgressHUD.show(withStatus: "Uploading photo...")
        avatarImagesRef.putData(imageData, metadata: metadata) { (metadata, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            // avatar uploaded
            if let avatarDownloadURL = metadata?.downloadURL()?.absoluteString {
                UserDefaults.standard.set(avatarDownloadURL, forKey: "avatarDownloadURL")
                
                guard let userID = self.getCurrentUserID() else { return }
                self.databaseRef.child("users").child(userID).child("photo").setValue(avatarDownloadURL)
                block(avatarDownloadURL)
            } else {
                block(nil)
            }
        }
    }
    
    func getUserFriends(block: @escaping ([User]) -> Swift.Void) {
        guard let userID = getCurrentUserID() else {
            SVProgressHUD.dismiss()
            return
        }
        
        var friendsArr: [User] = []
        
        databaseRef.child("users").child(userID).child("friends").observeSingleEvent(of: .value, with: { friends in
            guard let friendsJson = friends.value as? NSDictionary else {
                SVProgressHUD.dismiss()
                return
            }
            
            for (key, _) in friendsJson {
                self.getUserByID(id: key as! String) { user in
                    friendsArr.append(user)
                    
                    if friendsArr.count == friendsJson.count {
                        
                        self.friends = friendsArr
                        block(friendsArr)
                    }
                }
            }
        })
    }
    
    func getUserFriendIds(block: @escaping ([String]) -> Swift.Void) {
        guard let userId = getCurrentUserID() else {return}
        var ids: [String] = []
        
        databaseRef.child("users").child(userId).child("friends").observeSingleEvent(of: .value, with: { friends in
            if let friendsJson = friends.value as? NSDictionary {
                for (key, _) in friendsJson {
                    ids.append(key as! String)
                }
            }
            block(ids)
            
        })
    }
    
    func getAllUsers(block: @escaping ([User]) -> Swift.Void) {
        var usersArr: [User] = []
        databaseRef.child("users").observeSingleEvent(of: .value, with: {snapshot in
            usersArr = User().map(snapshot.value)
            usersArr = usersArr.filter({$0.id != self.getCurrentUserID()})
            block(usersArr)
        })
    }
    
    func syncAppContacts(contactPhones: [String]) {
        getAllUsers { (allUsers) in
            if allUsers.count > 0 {
                
                self.getUserFriendIds(block: { (friendIds) in
                
                    var updateFriends = false
                    for user in allUsers {
                        if !friendIds.contains(user.id!) {
                            if !(user.phoneNumber?.isEmpty)! {
                                
                                if contactPhones.contains((user.phoneNumber?.replacingOccurrences(of: "+", with: ""))!) {
                                    
                                    self.addNewFriend(with: user.id!)
                                    updateFriends = true
                                }
                                
                            }
                        }
                    }
                    
                    if updateFriends {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updated_friends"), object: nil)
                    }
                    
                })
                
            } 
        }
    }
    
    func createGroupChat(title: String, subject: String, photo: UIImage?, membersIDs: [String], block: @escaping (String) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        
        let newGroupRef = databaseRef.child("users").child(userID).child("dialogs").childByAutoId()
        block(newGroupRef.key)
        
        newGroupRef.setValue([
            "dialogID": newGroupRef.key,
            "type": "Group",
            "occupantsIds": membersIDs,
            "title": title,
            "saveMedia": true,
            "mute": false,
            "notification": true,
            "subject": subject,
            "adminId": userID
            ])

        for memberID in membersIDs {
            let friendGroupRef = databaseRef.child("users").child(memberID).child("dialogs").child(newGroupRef.key)
            
            friendGroupRef.setValue([
                "dialogID": newGroupRef.key,
                "type": "Group",
                "occupantsIds": [userID],
                "title": title,
                "saveMedia": true,
                "mute": false,
                "notification": true,
                "subject": subject,
                "adminId": userID
                ])
        }
        
        if let photo = photo, let imageData = UIImageJPEGRepresentation(photo, 0.8) {
            let groupPhotoRef = storageRef.child("images/group/" + newGroupRef.key + ".jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            SVProgressHUD.show(withStatus: "Uploading photo...")
            groupPhotoRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    return
                }
                if let groupPhotoURL = metadata?.downloadURL()?.absoluteString {
                    newGroupRef.child("photo").setValue(groupPhotoURL)
                    for memberID in membersIDs {
                        let friendGroupRef = self.databaseRef.child("users").child(memberID).child("dialogs").child(newGroupRef.key)
                        friendGroupRef.child("photo").setValue(groupPhotoURL)
                    }
                }
            }
        }
        SVProgressHUD.dismiss()
    }
    
    func updateGroupChat(originalGroup: Chat, changedGroup: Chat, newGroupPhoto: UIImage?) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()

        let currUserGroupRef = databaseRef.child("users").child(userID).child("dialogs").child(originalGroup.dialogID)
        
        if newGroupPhoto != nil {
            // Download new photo
            if let imageData = UIImageJPEGRepresentation(newGroupPhoto!, 0.8) {
                let groupPhotoRef = storageRef.child("images/group/" + originalGroup.dialogID + ".jpg")
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                SVProgressHUD.show(withStatus: "Uploading photo...")
                groupPhotoRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                        return
                    }
                    if let groupPhotoURL = metadata?.downloadURL()?.absoluteString {
                        currUserGroupRef.child("photo").setValue(groupPhotoURL)
                        for memberID in originalGroup.occupantsIds {
                            let friendGroupRef = self.databaseRef.child("users").child(memberID).child("dialogs").child(originalGroup.dialogID)
                            friendGroupRef.child("photo").setValue(groupPhotoURL)
                        }
                    }
                }
            }
        }
        
        for memberID in originalGroup.occupantsIds {
            let friendGroupRef = self.databaseRef.child("users").child(memberID).child("dialogs").child(originalGroup.dialogID)
            friendGroupRef.updateChildValues([
                "title": changedGroup.title,
                "saveMedia": changedGroup.saveMedia,
                "mute": changedGroup.mute,
                "notification": changedGroup.notification,
                "subject": changedGroup.subject,
                ])
        }
        
        currUserGroupRef.updateChildValues([
            "title": changedGroup.title,
            "saveMedia": changedGroup.saveMedia,
            "mute": changedGroup.mute,
            "notification": changedGroup.notification,
            "subject": changedGroup.subject,
            ]) {_, _ in
                SVProgressHUD.dismiss()
        }
    }
    
    func deleteGroup(group: Chat) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        
        // Delete all group messages
        let messagesRef = databaseRef.child("messages").child(group.dialogID)
        messagesRef.removeValue()
        
        // Delete dialog for current user
        let currUserGroupRef = databaseRef.child("users").child(userID).child("dialogs").child(group.dialogID)
        currUserGroupRef.removeValue()
        
        // Delete dialog for every group member
        for memberID in group.occupantsIds {
            let friendGroupRef = self.databaseRef.child("users").child(memberID).child("dialogs").child(group.dialogID)
            friendGroupRef.removeValue()
        }
        SVProgressHUD.dismiss()
    }
    
    func deleteUserFromGroup(group: Chat, userID: String) {
        guard let currUserID = getCurrentUserID() else { return }
        
        if let index = group.occupantsIds.index(where: {$0 == userID}) {
            // Delete for current user
            let currUserGroupMembersRef = databaseRef.child("users").child(currUserID).child("dialogs").child(group.dialogID).child("occupantsIds")
            currUserGroupMembersRef.child(index.description).removeValue()
        }
        
        // Delete for every group member
        for memberID in group.occupantsIds {
            let friendGroupRef = self.databaseRef.child("users").child(memberID).child("dialogs").child(group.dialogID).child("occupantsIds")
            friendGroupRef.child(userID).removeValue()
        }
        
        // Delete dialog for deleted user
        let removedDialogRef = databaseRef.child("users").child(userID).child("dialogs").child(group.dialogID)
        removedDialogRef.removeValue()
    }
    
    
    func changeNotificationValueForGroup(withID groupID: String, newValue: Bool) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        
        databaseRef.child("users").child(userID).child("dialogs").child(groupID).child("notification").setValue(newValue) { error, ref in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    public struct Group {
        var dialogID: String = ""
        var type: String = ""
        var occupantsIds: [String] = []
        var title: String = ""
        var saveMedia: Bool = true
        var mute: Bool = false
        var notification: Bool = true
        var subject: String = ""
        var adminId: String = ""
        var photo: String = ""
        var lastMessage: String = ""
        var lastMessageDateSent: Double = 0.0
        var lastMessageType: String = ""
        var lastSeenDate: Double = 0.0
    }
    
    func addNewGroupMembers(groupID: String, newMembersIDs: [String]) {
        guard let userID = getCurrentUserID() else { return }
        SVProgressHUD.show()
        
        var membersIDs = newMembersIDs
        
        /*
         3. update member list for current user
         4. add current user to this list for other members
         4. users.filter{$0.id != memberID}
         5. send group info to new members
         */
        
        // update member list for current user
        let occupantsIDsRef = databaseRef.child("users").child(userID).child("dialogs").child(groupID).child("occupantsIds")
        occupantsIDsRef.setValue(newMembersIDs) { error, _ in
            if let error = error {
                print(error.localizedDescription)
            }
            SVProgressHUD.dismiss()
        }
        
        // 4. add current user to this list for other members
        membersIDs.append(userID)
        
        // users.filter{$0.id != memberID} 
        for memberID in membersIDs {
            let dialogMembersRef = databaseRef.child("users").child(memberID).child("dialogs").child(groupID).child("occupantsIds")
            dialogMembersRef.setValue(newMembersIDs.filter{$0 != memberID}) { error, _ in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        // get group info and then send it to new occupants
        databaseRef.child("users").child(userID).child("dialogs").child(groupID).observeSingleEvent(of: .value, with: { groupInfoJSON in
            guard let groupInfo = groupInfoJSON.value as? NSDictionary else { return }
            
            var group = Group()
            
            if let dialogID = groupInfo.value(forKey: "dialogID")                       as? String   { group.dialogID = dialogID }
            if let type = groupInfo.value(forKey: "type")                               as? String   { group.type = type }
            if let occupantsIds = groupInfo.value(forKey: "occupantsIds")               as? [String] { group.occupantsIds = occupantsIds }
            if let title = groupInfo.value(forKey: "title")                             as? String   { group.title = title }
            if let saveMedia = groupInfo.value(forKey: "saveMedia")                     as? Bool     { group.saveMedia = saveMedia }
            if let mute = groupInfo.value(forKey: "mute")                               as? Bool     { group.mute = mute }
            if let notification = groupInfo.value(forKey: "notification")               as? Bool     { group.notification = notification }
            if let subject = groupInfo.value(forKey: "subject")                         as? String   { group.subject = subject }
            if let adminId = groupInfo.value(forKey: "adminId")                         as? String   { group.adminId = adminId }
            if let photo = groupInfo.value(forKey: "photo")                             as? String   { group.photo = photo }
            if let lastMessage = groupInfo.value(forKey: "lastMessage")                 as? String   { group.lastMessage = lastMessage }
            if let lastMessageDateSent = groupInfo.value(forKey: "lastMessageDateSent") as? Double   { group.lastMessageDateSent = lastMessageDateSent }
            if let lastMessageType = groupInfo.value(forKey: "lastMessageType")         as? String   { group.lastMessageType = lastMessageType }
            if let lastSeenDate = groupInfo.value(forKey: "lastSeenDate")               as? Double   { group.lastSeenDate = lastSeenDate }
            
            for newMembersID in newMembersIDs {
                let groupRef = self.databaseRef.child("users").child(newMembersID).child("dialogs").child(groupID)
                groupRef.child("dialogID").setValue(group.dialogID)
                groupRef.child("type").setValue("Group")
                groupRef.child("occupantsIds").setValue(membersIDs.filter{$0 != newMembersID})
                groupRef.child("title").setValue(group.title)
                groupRef.child("saveMedia").setValue(group.saveMedia)
                groupRef.child("mute").setValue(group.mute)
                groupRef.child("notification").setValue(true)
                groupRef.child("subject").setValue(group.subject)
                groupRef.child("adminId").setValue(group.adminId)
                groupRef.child("photo").setValue(group.photo)
                groupRef.child("lastMessage").setValue(group.lastMessage)
                groupRef.child("lastMessageDateSent").setValue(group.lastMessageDateSent)
                groupRef.child("lastMessageType").setValue(group.lastMessageType)
                groupRef.child("lastSeenDate").setValue(group.lastSeenDate)
            }
        })
    }
    
    func getIndividualRoomID(forUserID friendID: String, block: @escaping (String) -> Swift.Void) {
        guard let userID = getCurrentUserID() else { return }
        
        var individualRoomID = ""
        
        databaseRef.child("messages").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(userID + "_" + friendID) {
                individualRoomID = userID + "_" + friendID
            } else {
                individualRoomID = friendID + "_" + userID
            }
            block(individualRoomID)
        })
    }
    
    func deleteSingleChatMessage(withKey messageKey: String, friendID: String) {
        guard let userID = getCurrentUserID() else { return }
        
        let dataSent: Double = Date().timeIntervalSince1970
        databaseRef.child("users").child(userID).child("lastSeen").setValue(dataSent)
        
        getIndividualRoomID(forUserID: friendID) { roomID in
            
            if let username = UserDefaults.standard.string(forKey: "username") {
                
                let messagesRef = self.databaseRef.child("messages").child(roomID).child(messageKey)
                messagesRef.updateChildValues([
                    "message": username + " deleted a message",
                    ])
                
                let senderDialogRef = self.databaseRef.child("users").child(userID).child("dialogs").child("individual_" + friendID)
                senderDialogRef.updateChildValues([
                    "lastMessage": username + " deleted a message",
                    ])
                
                let friendDialogRef = self.databaseRef.child("users").child(friendID).child("dialogs").child("individual_" + userID)
                friendDialogRef.updateChildValues([
                    "lastMessage": username + " deleted a message",
                    ])
            }
        }
    }
    
    func deleteGroupMessage(withKey messageKey: String, inRoom roomID: String, chatMembers: [String]) {
        guard let userID = getCurrentUserID() else { return }
        
        let dataSent: Double = Date().timeIntervalSince1970
        databaseRef.child("users").child(userID).child("lastSeen").setValue(dataSent)
        
        var username2 = ""
        
        let messagesRef = databaseRef.child("messages").child(roomID)
        if let username = UserDefaults.standard.string(forKey: "username") {
            username2 = username
            messagesRef.child(messageKey).updateChildValues(["message": username + " deleted a message"])
        }
        
        let senderDialogRef = databaseRef.child("users").child(userID).child("dialogs").child(roomID)
        senderDialogRef.updateChildValues([
            "lastMessage": username2 + " deleted a message",
            ])
        
        for chatMemberID in chatMembers {
            let friendDialogRef = self.databaseRef.child("users").child(chatMemberID).child("dialogs").child(roomID)
            friendDialogRef.updateChildValues([
                "lastMessage": username2 + " deleted a message",
                ])
        }
    }
    
    func sendMessage(message: String, type: String, toFriend friend: User) {
        guard let userID = getCurrentUserID() else { return }
        
        let dataSent: Double = Date().timeIntervalSince1970
        databaseRef.child("users").child(userID).child("lastSeen").setValue(dataSent)
        
        getIndividualRoomID(forUserID: friend.id!) { roomID in
            let messagesRef = self.databaseRef.child("messages").child(roomID).childByAutoId()
            messagesRef.setValue([
                "dateSent": dataSent,
                "message": message,
                "type": type,
                "userID": userID,
                ])
        }
        
        let senderDialogRef = databaseRef.child("users").child(userID).child("dialogs").child("individual_" + friend.id!)
        senderDialogRef.updateChildValues([
            "lastMessage": message,
            "lastMessageDateSent": dataSent,
            "lastMessageType": type,
            "lastSeenDate": dataSent
            ])
        
        let friendDialogRef = self.databaseRef.child("users").child(friend.id!).child("dialogs").child("individual_" + userID)
        friendDialogRef.updateChildValues([
            "lastMessageType" : type,
            "lastMessage": message,
            "lastMessageDateSent": dataSent
            ])
    }
    
    func sendMessage(withText message: String, type: String, chat: Chat) {
        guard let userID = getCurrentUserID() else { return }
        
        let dataSent: Double = Date().timeIntervalSince1970
        databaseRef.child("users").child(userID).child("lastSeen").setValue(dataSent)
        
        let dialogRef = databaseRef.child("messages").child(chat.dialogID).childByAutoId()
        dialogRef.setValue([
            "dateSent": dataSent,
            "message": message,
            "type": type,
            "userID": userID,
            ])
        
        let senderRef = databaseRef.child("users").child(userID).child("dialogs").child(chat.dialogID)
        
        senderRef.updateChildValues([
            "lastMessage": message,
            "lastMessageDateSent": dataSent,
            "lastMessageType": type,
            "lastSeenDate": dataSent
            ])

        for chatMemberID in chat.occupantsIds {
            let chatRef = self.databaseRef.child("users").child(chatMemberID).child("dialogs").child(chat.dialogID)
            chatRef.updateChildValues([
                "lastMessageType" : type,
                "lastMessage": message,
                "lastMessageDateSent": dataSent
                ])
            
            if chat.notification, let username = UserDefaults.standard.string(forKey: "username") {
                
                databaseRef.child("users").child(chatMemberID).child("pushToken").observeSingleEvent(of: .value, with: { pushTokenJSON in
                    guard let pushToken = pushTokenJSON.value as? String else { return }
                    FirebaseManager.shared.sendNotification(title: username, message: message, userToken: pushToken)
                })
            }
        }
    }
    
    func sendNotification(title: String, message: String, userToken: String) {
//        if userToken != nil {
            var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAAsO3s-LM:APA91bF2wCvdJIpw4ZfDVatBRBRF9yHVmMf5RT7wJtZ2_BmwJNPgTIViitaNfT6nGVYofjezo41MOQ9lBqsyCmD3SriVmeDs8sYG_msJ5YLx72KQ8cEN7cbw3a5-SrwV5KmhvarQ8RHe", forHTTPHeaderField: "Authorization")
            let json = [
                "to" : userToken,
                "priority" : "high",
                "notification" : [
                    "title" : title,
                    "body"  : message,
                    "badge" : 1
                ]
                ] as [String : Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        // check for http errors
                        print("Status Code should be 200, but is \(httpStatus.statusCode)")
                        print("Response = \(String(describing: response))")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                }
                task.resume()
            }
            catch {
                print(error)
            }
//        }
    }
    
    
    
}
