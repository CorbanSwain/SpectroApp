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
    
    var dateSection: DateSection {
        get {
            return DateSection(rawValue: dateSectionDB) ?? .undated
        } set {
            dateSectionDB = newValue.rawValue
        }
    }
    
    var notes: String {
        get {
            return notesDB ?? "no notes"
        } set {
            notesDB = newValue
        }
    }
    
    var notebookReference: String {
        get {
            return notebookReferenceDB ?? "no notebook reference"
        } set {
            notebookReferenceDB = newValue
        }
    }
    
    var title: String {
        get {
            return titleDB ?? "untitled"
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
            experimentTypeStringDB = newValue.description
        }
    }
    
    var creationDate: Date? {
        get {
            return creationDateDB as Date?
        } set {
            creationDateDB = newValue as NSDate?
        }
    }
    
    var editDate: Date? {
        get {
            return editDateDB as Date?
        } set {
            editDateDB = newValue as NSDate?
            refreshDateSection()
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
    
    func refreshDateSection() {
        guard let editDate = editDate else {
            dateSection = .undated
            return
        }
        for section in DateSection.sectionArray {
            //            print("Section Date: \(Formatter.monDayYr.string(from: section.date)) -- \(Formatter.monDayYrHrMin.string(from: editDate)) :Edit Date\n\t↳ Project.resreshDateSection()")
            switch section.date.compare(editDate) {
            case .orderedAscending, .orderedSame:
                //                print("ordered ascending or same:\n\t↳ Project.resreshDateSection()")
                //                print("SECTION: \(section.header)\n\t↳ Project.resreshDateSection()");
                dateSection = section
                return
            default:
                continue
            }
        }
        dateSection = .older
    }
    
    // FIXME: - implement with user defaults or core data
    static var lastDateSectionRefresh: Date?
    
    class func refreshAllDateSections() -> Bool {
        if let date = lastDateSectionRefresh {
            if date.timeIntervalSinceNow < (-60 * 60 * 23.99999) {
                print("Time up! - refresfing!\n\t↳ Project.refreshAllDateSections()")
                lastDateSectionRefresh = nil
                return refreshAllDateSections()
            }
        } else {
            lastDateSectionRefresh = DateSection.today.date
            let request: NSFetchRequest<Project> = fetchRequest()
            do {
                let allProjects = try AppDelegate.viewContext.fetch(request)
                print("Refreshing all date sections.\n\t↳ Project.refreshAllDateSections()")
                for proj in allProjects { proj.refreshDateSection() }
                return true
            } catch let error as NSError {
                print("ERROR: Could not fetch all projects. --> Description: \(error.debugDescription)\n\t↳ Project.refreshAllDateSections()")
                return false
            }
        }
        return false
    }
}
