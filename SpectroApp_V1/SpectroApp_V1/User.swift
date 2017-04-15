//
//  User.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

@objc(User)
class User: NSManagedObject {

    var username: String {
        get {
            return usernameDB ?? "no username"
        }
    }
    
}
