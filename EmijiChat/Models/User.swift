//
//  User.swift
//  EmijiChat
//
//  Created by Star on 10/13/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Equatable, Mappable {
    var id: String?
    var contact_id: String?
    var firstname: String?
    var lastname: String?
    var username: String?
    var photo: String?
    var lastSeen: Double?
    var notification: Bool?
    var pushToken: String?
    var phoneNumber: String?
    
    init(){
        
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        contact_id <- map["contact_id"]
        username <- map["username"]
        phoneNumber <- map["phoneNumber"]
    }
    
    func map(_ json: Any?) -> [User] {
        var users: [User] = []
        let usersDict = json as? NSDictionary
        
        guard let usersArr = usersDict else {
            return []
        }
        
        for (key, _) in usersArr {
            let userTmp = User()
            let contact: NSObject = usersDict![key] as! NSObject
            userTmp.id = contact.value(forKey: "id") as? String ?? ""
            userTmp.firstname = contact.value(forKey: "firstname") as? String ?? ""
            userTmp.lastname = contact.value(forKey: "lastname") as? String ?? ""
            userTmp.username = contact.value(forKey: "username") as? String ?? ""
            userTmp.phoneNumber = contact.value(forKey: "mobile") as? String ?? ""
            userTmp.photo = contact.value(forKey: "photo") as? String ?? ""
            userTmp.lastSeen = contact.value(forKey: "lastSeen") as? Double ?? 0
            userTmp.notification = contact.value(forKey: "notification") as? Bool ?? true
            userTmp.pushToken = contact.value(forKey: "pushToken") as? String ?? ""
            users.append(userTmp)
        }
        return users
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
