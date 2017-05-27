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

    var username: String? {
        get {
            return usernameDB
        } set {
            usernameDB = newValue
        }
    }
    
    var firstName: String? {
        get {
            return firstNameDB
        } set {
            firstNameDB = newValue
        }
    }
    
    var lastName: String? {
        get {
            return lastNameDB
        } set {
            lastNameDB = newValue
        }
    }
    
    convenience init(first: String, last: String, username: String) {
        self.init(context: AppDelegate.viewContext)
        firstName = first
        lastName = last
        self.username = username
    }
    
}
