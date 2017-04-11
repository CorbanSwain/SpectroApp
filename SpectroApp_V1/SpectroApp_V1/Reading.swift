//
//  Reading.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

class Reading: AbsorbanceObject {
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
        }
    }
    
    var dataPointArray: [DataPoint] {
        get {
            guard let points = dataPoints as? Set<DataPoint> else {
                return []
            }
            return points.sorted(by: {
                guard let t1 = $0.timestamp as? Date, let t2 = $1.timestamp as? Date else {
                    return true
                }
                switch t1.compare(t2) {
                case .orderedDescending: return true
                default: return false
                }
            })
        }
    }
    
    var readingType: ReadingType {
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
}
