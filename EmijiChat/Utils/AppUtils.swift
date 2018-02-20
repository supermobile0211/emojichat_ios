//
//  AppUtils.swift
//  EmijiChat
//
//  Created by Star on 10/14/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation

class AppUtils {
    
    static let shared = AppUtils()
    
    var workingUsers: [User] = []
    
    func addContct(_ user: User) {
        workingUsers.append(user)
    }
    
    func removeContact(_ user: User) {
        workingUsers = workingUsers.filter({$0.contact_id != user.contact_id})
    }
    
    func isSelectedContact(_ user: User) -> Bool {
        let result = workingUsers.filter({$0.contact_id == user.contact_id})
        if result.isEmpty {
            return false
        } else {
            return true
        }
    }
    
}
