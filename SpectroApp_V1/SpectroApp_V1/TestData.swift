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
    static private let words = ["Lorem", "Ipsum", "Dolor", "Sit", "Amet", "Sciency", "Measure", "Test", "Kanye", "Lift", "Spectral", "Graphene", "Nano", "Ribolyse", "Pitch", "Read", "Corral"]
    static var index = 0
    static var initialDate = Date()
    static var numPointsPerReading = 5
    static var experimentType = ExperimentType.cellDensity
    static var numReadings = 100
    static var baselineVal = 2800
    static var spread = 100
    static var readingTypeIndices: [Int] = [0,0,0, 0,0,0, 0,0]
    // static var projectTitle = "with C. Eligans"
    static var timeConverter: InstrumentTimeConverter {
        return InstrumentTimeConverter(instrumentMillis: 0, centralTime: initialDate)
    }
    
    static func createProject() -> Project {
        let proj = Project()
        proj.experimentType = ExperimentType(rawValue: Int16(rand(1,3))) ?? .noType
        proj.editDate = Date().addingTimeInterval(-(Double)(rand(0,20_000_000)))
        proj.notebookReference = "CS-IX-\(rand(10,99))"
        proj.title =  proj.experimentType.description + " " + randWords(3)
        proj.notes = randWords(15, sentence: true) + " " + randWords(10, sentence: true) + " " + randWords(20, sentence: true) + " " + randWords(17, sentence: true)
        //proj.notes = "hi"
        var reading: Reading
        var date: Date
        var dp: DataPoint
        var dps: [DataPoint] = []
        var idp: InstrumentDataPoint
        var val: Int
        var specificVal: Int
        var readingTypeInt: Int16
        var tag: (ReadingType, Int)
        var millis: UInt32
        
        for _ in 0..<numReadings {
            
            val = rand(10, baselineVal)
            readingTypeInt = Int16(rand(0,7))
            date = proj.editDate!.addingTimeInterval(TimeInterval(rand(0,100_000)))
//            print("i:\(i) - val:\(val)- ReadingTypeInt:\(readingTypeInt)")
            for _ in 0..<rand(2,6) {
                specificVal = val + rand(-spread/2, spread/2)
                tag = (ReadingType(rawValue: readingTypeInt)!, readingTypeIndices[Int(readingTypeInt)])
                millis = InstrumentTimeConverter.millis(fromDate: initialDate)
                idp = InstrumentDataPoint(index: index, value: specificVal, tag: tag, uuid: UUID(), timestamp: millis)
//                print("     j:\(j) - \(idp.customDescription)")
                index += 1
                dp = DataPoint(fromIDP: idp, usingTimeConverter: timeConverter)
                idp.dataPoint = dp
                dp.timestamp = date
                dp.title = randWords(1)
                dp.baselineValue = baselineVal
//                print("     j:\(j) - \(dp)")
                dps.append(dp)
            }
            
            readingTypeIndices[Int(readingTypeInt)] += 1
            reading = Reading(fromDataPoints: dps)
            for dp in dps {
                dp.reading = reading
            }
            dps = []
            reading.typeDB = readingTypeInt
            reading.project = proj
            reading.title = randWords(2)
//            print("i:\(i) \(reading)")
            proj.addToReadingsDB(reading)
        }
//        print(proj)
        return proj
    }
    
    static func rand(_ low: Int = 0, _ high: Int = 100) -> Int {
        guard high > low else {
            return 0
        }
        let range: UInt32 = UInt32(high - low + 1)
        return Int(arc4random() % range) + low
    }
    
    static func randWords(_ num: Int, sentence: Bool = false, from words: [String] = words, seperator: String = " ") -> String {
        guard num > 0 else {
            return ""
        }
        var w = ""
        var str = words[rand(0,words.count - 1)]
        if num > 1 {
            str += seperator
            for i in 0..<(num - 1) {
                w = words[rand(0,words.count - 1)]
                str += (sentence ? w.lowercased() : w)
                if i != num - 2 {
                    str += seperator
                }
            }
        }
        return str + (sentence ? "." : "")
    }
}
