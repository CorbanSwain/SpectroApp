//
//  Project.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

class Project: AbsorbanceObject {

    var readingSet: Set<Reading> {
        get {
            guard let r = readings as? Set<Reading> else {
                return []
            }
            return r
        }
    }
    
    var readingArray: [Reading] {
        get {
            return readingSet.sorted(by: {
                guard let t1 = $0.timestamp, let t2 = $1.timestamp else {
                    return true
                }
                switch t1.compare(t2) {
                case .orderedDescending: return true
                default: return false
                }
            })
        }
    }
    
    var experimentType: ExperimentType {
        get {
            return ExperimentType(rawValue: experimentTypeInt) ?? .noType
        } set {
            experimentTypeInt = newValue.rawValue
        }
    }
}
