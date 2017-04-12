//
//  Reading.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

@objc(Reading)
class Reading: AbsorbanceObject {
    
    static var entityDescr: NSEntityDescription { return NSEntityDescription.entity(forEntityName: "Reading", in: AppDelegate.viewContext)! }
    
    var timestamp: Date? {
        guard let t1 = dataPointArray[0].timestamp as? Date else { return nil }
        return t1
    }
    
    var dataPointSet: Set<DataPoint> {
        get {
            guard let points = dataPoints as? Set<DataPoint> else {
                return []
            }
            return points
        } set {
            for point in newValue {
                point.reading = self
            }
            dataPoints = newValue as NSSet?
        }
    }
    
    var dataPointArray: [DataPoint] {
        get {
            return dataPointSet.sorted(by: {
                guard let t1 = $0.timestamp as? Date, let t2 = $1.timestamp as? Date else {
                    return true
                }
                switch t1.compare(t2) {
                case .orderedDescending: return true
                default: return false
                }
            })
        } set {
            dataPoints = []
            for point in newValue {
                addToDataPoints(point)
                point.reading = self
            }
        }
    }
    
    var type: ReadingType {
        get {
            return ReadingType(rawValue: typeInt) ?? .noType
        } set {
            typeInt = newValue.rawValue
        }
    }
    
    var isEmpty: Bool { return dataPointSet.count < 1 }
    var hasRepeats: Bool { return dataPointSet.count > 1 }
    var absorbanceValue: CGFloat? { return average(ofPoints: dataPointSet) }
    var stdDev: CGFloat? { return stdev(ofPoints: dataPointSet) }
    
    convenience init(fromDataPoints dataPoints: Set<DataPoint>) {
        //self.init(entity: Reading.entityDescr, insertInto: AppDelegate.viewContext)
        self.init(context: AppDelegate.viewContext)
        dataPointSet = dataPoints
    }
}
