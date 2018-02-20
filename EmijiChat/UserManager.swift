//
//  UserManager.swift
//  EmijiChat
//
//  Created by Bender on 26.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation

class UserManager {
    
    static func isLogged() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLogged")
    }
    
    static func login(username: String, withPhone phone: String) {
        UserDefaults.standard.set(true, forKey: "isLogged")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.synchronize()
    }
    
    static func logout() {
        UserDefaults.standard.removeObject(forKey: "isLogged")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "phone")
        UserDefaults.standard.synchronize()
    }
}
