//
//  Reading.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

struct Reading {
    var readingName: String
    var timestamp: Date
    var hashValue: Int
    var experimentType: AbsorbanceKit.ExperimentType
    var readingType: AbsorbanceKit.ReadingType
    
    var dataPoints: [DataPoint] = []
    var wavelength: AbsorbanceKit.Wavelength?
    var calibrationPoints: [DataPoint] = []
    var calibrationWavelength: AbsorbanceKit.Wavelength?
    
    var isEmpty: Bool { return dataPoints.count < 1 }
    var hasRepeats: Bool { return dataPoints.count > 1 }
    var absorbanceValue: CGFloat? { return AbsorbanceKit.average(of: dataPoints) }
    var stdDev: CGFloat? { return AbsorbanceKit.stdev(of: dataPoints) }
}
