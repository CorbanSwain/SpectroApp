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
    
    var dateSectionString: String {
        return dateSection.header
    }
    
    var dateSectionInt: String {
        return dateSection.header
    }
    
    var dateSection: DateSection {
//        guard let editDate = editDate else {
//            return .undated
//        }
        for section in DateSection.sectionArray {
            print("Section Date: \(Formatter.monDayYr.string(from: section.date)) -- \(Formatter.monDayYr.string(from: editDate)) :Edit Date")
            switch section.date.compare(editDate) {
            case .orderedAscending, .orderedSame:
                return DateSection(rawValue: section.rawValue) ?? .undated
            default:
                continue
            }
        }
        return .older
    }
    
    var notes: String? {
        get {
            return notesDB
        } set {
            notesDB = newValue
        }
    }
    
    var notebookReference: String? {
        get {
            return notebookReferenceDB
        } set {
            notebookReferenceDB = newValue
        }
    }
    
    var title: String? {
        get {
            return titleDB
        } set {
            titleDB = newValue
        }
    }
    
    var readings: Set<Reading> {
        get {
            guard let r = readingsDB as? Set<Reading> else {
                return []
            }
            return r
        } set {
            for r in newValue {
                r.project = self
            }
            readingsDB = newValue as NSSet
        }
    }
    
    var readingArray: [Reading] {
        get {
            return readings.sorted(by: {
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
                addToReadingsDB(r)
            }
        }
    }
    
    var experimentType: ExperimentType {
        get {
            return ExperimentType(rawValue: experimentTypeDB) ?? .noType
        } set {
            experimentTypeDB = newValue.rawValue
        }
    }
    
    var creationDate: Date? {
        get {
            return creationDateDB as Date?
        }
    }
    
    var editDate: Date {
        get {
            return editDateDB! as Date
        } set {
            editDateDB = newValue as NSDate
            dateSectionDB = dateSection.rawValue
            dateSectionStringDB = dateSection.header
        }
    }
    
    convenience init() {
        self.init(context: AppDelegate.viewContext)
        creationDateDB = Date() as NSDate
    }

    
    convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
}
