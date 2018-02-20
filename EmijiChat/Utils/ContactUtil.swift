//
//  ContactUtil.swift
//  EmijiChat
//
//  Created by Star on 10/13/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation
import Contacts
import ObjectMapper

class ContactUtil {
    
    let CONTACT_LOADED = "contact_loaded"
    var addedContacts: [User] = []
    var updatedContacts: [User] = []
    var deletedContacts: [String] = []
    var contactBookInfo: [User] = []
    var contactBookInfoWithoutFriends: [User] = []
    
    let prefs = UserDefaults.standard
    
    static let shared = ContactUtil()
    
    private init() {}
    
    func syncContacts(_ completionHandler:@escaping (_ result : Bool) -> Void) {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) in
            if accessGranted {
                self.contactBookInfo = self.getContacts()
                let loaded = self.prefs.bool(forKey: self.CONTACT_LOADED)
                print("Start syncContacts")
                if loaded {
                    if self.isContactBookChanged(newContacts: self.contactBookInfo) {
                        self.clearContact()
                        self.saveContacts(self.contactBookInfo)
                    }
                } else {
                    self.saveContacts(self.contactBookInfo)
                }
                print("End syncContacts")
                self.prefs.set(true, forKey: self.CONTACT_LOADED)
                self.prefs.synchronize()
                
            }
            completionHandler(accessGranted)
        }
    }
    
    func getContacts() -> [User]  {
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactIdentifierKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey,
            CNContactDatesKey
            ] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        if #available(iOS 10.0, *) {
            fetchRequest.mutableObjects = false
        } else {
            // Fallback on earlier versions
        }
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .userDefault
        
        let contactStoreID = CNContactStore().defaultContainerIdentifier()
        print("\(contactStoreID)")
        
        var contacts: [User] = []
        do {
            try CNContactStore().enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) in
                if contact.phoneNumbers.count > 0 {
                    var phone_number = contact.phoneNumbers.first?.value.value(forKey: "digits") as? String
                    phone_number = phone_number?.replacingOccurrences(of: "+", with: "")
                    
                    let user = User()
                    user.contact_id = contact.identifier
                    user.phoneNumber = phone_number
                    user.username = "\(contact.givenName) \(contact.familyName)"
                    contacts.append(user)
                }
            })
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return contacts
    }
    
    func isContactBookChanged(newContacts: [User]) -> Bool {
        
        let oldContacts = loadContacts()
        
        self.addedContacts.removeAll()
        self.updatedContacts.removeAll()
        self.deletedContacts.removeAll()
        
        for newItem in newContacts {
            
            var isNew = true
            for oldItem in oldContacts {
                if newItem.contact_id == oldItem.contact_id {
                    isNew = false
                    if newItem.username == oldItem.username {
                        if newItem.phoneNumber != nil {
                            if newItem.phoneNumber != oldItem.phoneNumber {
                                self.updatedContacts.append(newItem)
                            }
                        }
                    } else {
                        self.updatedContacts.append(newItem)
                    }
                    break
                }
            }
            
            if isNew {
                self.addedContacts.append(newItem)
            }
            
        }
        
        for oldItem in oldContacts {
            var isDeleted = true
            for newItem in newContacts {
                if oldItem.contact_id == newItem.contact_id {
                    isDeleted = false
                    break
                }
            }
            
            if isDeleted {
                self.deletedContacts.append(oldItem.contact_id!)
            }
        }
        
        let isChanged = !self.addedContacts.isEmpty || !self.updatedContacts.isEmpty || !self.deletedContacts.isEmpty
        
        return isChanged
    }
    
    func makeContactInfoWithoutFriends(friends: [User]) {
        var temps: [User] = []
        if contactBookInfo.isEmpty  {
            contactBookInfo = loadContacts()
        } else {
            if friends.count > 0 {
                for contact in contactBookInfo {
                    if contact.phoneNumber != nil {
                        var isExisting = false
                        for f in friends {
                            if contact.phoneNumber?.replacingOccurrences(of: "+", with: "") == f.phoneNumber?.replacingOccurrences(of: "+", with: "") {
                                isExisting = true
                                break;
                            }
                        }
                        if !isExisting {
                            temps.append(contact)
                        }
                    }
                }
                contactBookInfoWithoutFriends = temps
            } else {
                contactBookInfoWithoutFriends = contactBookInfo
            }
            
            contactBookInfoWithoutFriends = contactBookInfoWithoutFriends.sorted(by: {$0.username! < $1.username!})
            
        }
    }
    
}

extension ContactUtil {
    
    fileprivate func saveContacts(_ contacts: [User]) {
        
        prefs.set(Date().timeIntervalSince1970, forKey: "lastUpdatedTime")
        prefs.synchronize()
        
        var strArray: [String] = []
        for contact in contacts {
            let str = contact.toJSONString(prettyPrint: true) ?? ""
            strArray.append(str)
        }
        
        let path = getImportPath()
        
        (strArray as NSArray).write(toFile: path, atomically: true)
        if FileManager.default.fileExists(atPath: path) {
            print(path)
        } else {
            print("file does not exist.")
        }
        let phones = getContactPhones(contacts)
        FirebaseManager.shared.syncAppContacts(contactPhones: phones)
        
    }
    
    fileprivate func getContactPhones(_ contacts: [User]) -> [String] {
        var phones: [String] = []
        for contact in contacts {
            if !(contact.phoneNumber?.isEmpty)! {
                phones.append(contact.phoneNumber!)
            }
        }
        return phones
    }
    
    fileprivate func loadContacts() -> [User] {
        
        let path = getImportPath()
        let array = NSArray(contentsOfFile: path)
        if let array = array {
            var contacts:[User] = []
            for jsonString in array {
                let user = User(JSONString: jsonString as! String)
                contacts.append(user!)
            }
            return contacts
        } else {
            return []
        }
        
    }
    
    fileprivate func clearContact() {
        
        prefs.removeObject(forKey: "lastUpdatedTime")
        let path = getImportPath()
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("ClearContact was failed")
        }
        
    }
    
    fileprivate func getImportPath() -> String {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("import.txt")
            return fileUrl.relativePath
        } catch {
            return ""
        }
        
        
    }
    
}

