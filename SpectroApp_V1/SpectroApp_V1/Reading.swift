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
    var projectID: UUID
    
    var readingName: String
    var timestamp: Date
    
    // fix me!
    var hashValue: Int
    
    var experimentType: ExperimentType
    var readingType: ReadingType
    
    var dataPoints: [DataPoint] = []
    var wavelength: Wavelength
    var calibrationPoints: [DataPoint]? = []
    var calibrationWavelength: Wavelength?
    
    var isEmpty: Bool { return dataPoints.count < 1 }
    var hasRepeats: Bool { return dataPoints.count > 1 }
    var absorbanceValue: CGFloat? { return average(of: dataPoints) }
    var stdDev: CGFloat? { return stdev(of: dataPoints) }
}
