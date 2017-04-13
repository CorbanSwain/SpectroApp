//
//  Project.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

@objc(Project)
class Project: AbsorbanceObject {

    static var entityDescr: NSEntityDescription { return NSEntityDescription.entity(forEntityName: "Project", in: AppDelegate.viewContext)! }
    
    var readingSet: Set<Reading> {
        get {
            guard let r = readings as? Set<Reading> else {
                return []
            }
            return r
        } set {
            for r in newValue {
                r.project = self
            }
            readings = newValue as NSSet
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
        } set {
            readings = []
            for r in newValue {
                r.project = self
                addToReadings(r)
            }
        }
    }
    
    var experimentType: ExperimentType {
        get {
            return ExperimentType(rawValue: experimentTypeInt) ?? .noType
        } set {
            experimentTypeInt = newValue.rawValue
        }
    }
    
    convenience init() {
        //self.init(entity: Project.entityDescr, insertInto: AppDelegate.viewContext)
        self.init(context: AppDelegate.viewContext)
        timestamp = Date() as NSDate
    }

    
    convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
}
