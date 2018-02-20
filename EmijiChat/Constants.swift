//
//  Constants.swift
//  EmijiChat
//
//  Created by Bender on 26.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct Configuration {
        static let UseWorkaround = true
    }
    
    struct Device {
        static let Identifier = UIDevice.current.identifierForVendor?.uuidString
    }
    
    struct UI {
        static let barColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
        static let barColorTransparent = UIColor(red: 0.33896, green: 0.65374, blue: 0.982395, alpha: 1)
    }
    
}
