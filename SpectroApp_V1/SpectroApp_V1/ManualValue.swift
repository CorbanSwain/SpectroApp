//
//  ManualValue.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

@objc(ManualValue)
class ManualValue: NSManagedObject {
    var isSet: Bool {
        get {
            return isSetDB
        } set {
            isSetDB = newValue
        }
    }
    
    var measurementValue: CGFloat {
        get {
            return CGFloat(measurementValueDB)
        } set {
            measurementValueDB = Float(newValue)
        }
    }
    
    convenience init() {
        self.init(context: AppDelegate.viewContext)
    }
}
