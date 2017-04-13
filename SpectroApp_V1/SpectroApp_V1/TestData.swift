//
//  TestData.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation
import Darwin

class TestDataGenerator {
    static var index = 0
    static var initialDate = Date()
    static var numPointsPerReading = 5
    static var experimentType = ExperimentType.cellDensity
    static var numReadings = 100
    static var baselineVal = 2800
    static var spread = 10
    static var readingTypeIndices: [Int] = [0,0,0, 0,0,0, 0,0]
    static var projectTitle = "with C. Eligans"
    static var timeConverter: InstrumentTimeConverter {
        return InstrumentTimeConverter(instrumentMillis: 0, centralTime: initialDate)
    }
    
    static func createProject() -> Project {
        let proj = Project(withTitle: projectTitle)
        proj.experimentType = ExperimentType(rawValue: Int16(rand(1,3))) ?? .noType
        proj.timestamp = Date() as NSDate
        proj.title =  proj.experimentType.description + " " + projectTitle
        
        var reading: Reading
        var dp: DataPoint
        var dps: Set<DataPoint> = []
        var idp: InstrumentDataPoint
        var val: Int
        var specificVal: Int
        var readingTypeInt: Int16
        var tag: (ReadingType, Int)
        var millis: UInt32
        
        for _ in 0..<numReadings {
            
            val = rand(10, baselineVal)
            readingTypeInt = Int16(rand(0,8))
//            print("i:\(i) - val:\(val)- ReadingTypeInt:\(readingTypeInt)")
            for _ in 0..<numPointsPerReading {
                specificVal = val + rand(-spread/2, spread/2)
                tag = (ReadingType(rawValue: readingTypeInt)!, readingTypeIndices[Int(readingTypeInt)])
                millis = InstrumentTimeConverter.millis(fromDate: initialDate)
                idp = InstrumentDataPoint(index: index, value: specificVal, tag: tag, uuid: UUID(), timestamp: millis)
//                print("     j:\(j) - \(idp.customDescription)")
                index += 1
                dp = DataPoint(fromIDP: idp, usingTimeConverter: timeConverter)
                idp.dataPoint = dp
                dp.label = "A Title " + String(index)
                dp.baseline = baselineVal
//                print("     j:\(j) - \(dp)")
                dps.insert(dp)
            }
            
            readingTypeIndices[Int(readingTypeInt)] += 1
            reading = Reading(fromDataPoints: dps)
            for dp in dps {
                dp.reading = reading
            }
            dps = []
            reading.typeInt = readingTypeInt
            reading.project = proj
            reading.label = "Data-" + String(rand(1,10))
//            print("i:\(i) \(reading)")
            proj.addToReadings(reading)
        }
//        print(proj)
        return proj
    }
    
    static func rand(_ low: Int = 0, _ high: Int = 100) -> Int {
        guard high > low else {
            return 0
        }
        let range: UInt32 = UInt32(high - low)
        return Int(arc4random() % range) + low
    }
}
