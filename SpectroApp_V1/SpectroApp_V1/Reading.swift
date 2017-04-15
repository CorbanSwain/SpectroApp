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
    
    var title: String? {
        get {
            return titleDB
        }
        set {
            titleDB = newValue
        }
    }
    
    var timestamp: Date? {
        guard let t1 = dataPointArray[0].timestamp as Date? else { return nil }
        return t1
    }
    
    var dataPoints: Set<DataPoint> {
        get {
            guard let points = dataPointsDB as? Set<DataPoint> else {
                return []
            }
            return points
        } set {
            for point in newValue {
                point.reading = self
            }
            dataPointsDB = newValue as NSSet?
        }
    }
    
    var dataPointArray: [DataPoint] {
        get {
            return dataPoints.sorted(by: {
                guard let t1 = $0.timestamp, let t2 = $1.timestamp else {
                    return true
                }
                switch t1.compare(t2) {
                case .orderedDescending:
                    return true
                default:
                    return false
                }
            })
        } set {
            dataPoints = []
            for point in newValue {
                addToDataPointsDB(point)
                point.reading = self
            }
        }
    }
    
    var type: ReadingType {
        get {
            return ReadingType(rawValue: typeDB) ?? .noType
        } set {
            typeDB = newValue.rawValue
        }
    }
    
    var isEmpty: Bool { return dataPoints.count < 1 }
    var hasRepeats: Bool { return dataPoints.count > 1 }
    var absorbanceValue: CGFloat? { return average(ofPoints: dataPoints) }
    var stdDev: CGFloat? { return stdev(ofPoints: dataPoints) }
    
    var dataPointsStringArray: [String] {
        var result: [String] = []
        for point in dataPointArray {
            guard let val = point.measurementValue as NSNumber? else {
                continue
            }
            let numStr = Formatter.threeDecNum.string(from: val)
            result.append(numStr ?? "???")
        }
        return result
    }
    
    convenience init() {
        self.init(context: AppDelegate.viewContext)
    }
    
    convenience init(fromDataPoints dataPoints: Set<DataPoint>) {
        self.init()
        self.dataPoints = dataPoints
    }
}
