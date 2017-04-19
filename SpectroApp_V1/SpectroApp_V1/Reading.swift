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
    
    var concentration: CGFloat? {
        get {
            if hasConcentrationDB {
                return CGFloat(concentrationDB)
            } else {
                return nil
            }
        }
        set {
            if let val = newValue {
                concentrationDB = Float(val)
                hasConcentrationDB = true
            } else {
                hasConcentrationDB = false
            }
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
    
    
    var calibrationPoints: Set<DataPoint> {
        get {
            guard let points = calibrationPointsDB as? Set<DataPoint> else {
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
    
    var calibrationPointArray: [DataPoint] {
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
                addToCalibrationPointsDB(point)
                point.reading = self
            }
        }
    }
    
    var isEmptyCalibration: Bool { return calibrationPoints.count < 1 }
    var hasRepeatsCalibration: Bool { return calibrationPoints.count > 1 }
    var absorbanceValueCalibration: CGFloat? { return average(ofPoints: calibrationPoints) }
    var stdDevCalibration: CGFloat? { return stdev(ofPoints: calibrationPoints) }
    var calibrationRatio: CGFloat? {
        guard let a = absorbanceValue, let b = absorbanceValueCalibration else {
            return nil
        }
        return a / b
    }
    
    var calibrationPointsStringArray: [String] {
        var result: [String] = []
        for point in calibrationPointArray {
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
        
        // parse out most cmmon type tag from instrument datapoints
        var dict: [ReadingType:Int] = [:]
        for point in dataPoints {
            if let t = point.instrumentDataPoint?.tag.type {
                if dict[t] == nil {
                    dict[t] = 1
                } else {
                    dict[t] = dict[t]! + 1
                }
            }
        }
        var max = 0
        var popularType: ReadingType? = nil
        for item in dict {
            if item.value > max {
                max = item.value
                popularType = item.key
            }
        }
        type = popularType ?? .noType
    }
}
