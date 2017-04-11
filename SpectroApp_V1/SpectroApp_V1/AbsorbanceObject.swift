//
//  AbsorbanceObject.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

class AbsorbanceObject: NSManagedObject {
    var uuid: UUID {
        get {
            guard let str = uuidString, let id = UUID(uuidString: str) else {
                print("uuid is incomplete or nil")
                return UUID(uuid: UUID_NULL)
            }
            return id
        } set {
            uuidString = newValue.uuidString
        }
    }
    
}
