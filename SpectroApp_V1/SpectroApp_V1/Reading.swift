//
//  Reading.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

struct Reading {
    // ???????
    var projectID: UUID?
    
    var readingName: String
    // var timestamp: Date { COMPUTED VAL }
    
    // fix me! -- use UUID
    var readingID: UUID
    
    var readingType: ReadingType
    
    var dataPoints: [DataPoint] = []
    var calibrationPoints: [DataPoint]? = nil
    
    var isEmpty: Bool { return dataPoints.count < 1 }
    var hasRepeats: Bool { return dataPoints.count > 1 }
    var absorbanceValue: CGFloat? { return average(ofPoints: dataPoints) }
    var stdDev: CGFloat? { return stdev(ofPoints: dataPoints) }
}
