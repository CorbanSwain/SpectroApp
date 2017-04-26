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
    static private let names = ["Johnny", "Cash", "William", "Bradley", "Mary", "Pooja", "Samson", "Wilson", "Adam", "Tyler"]
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
        print("project notebook ref: \(proj.notebookReference ?? "[none]") \n\t↳ TestDataGenerator.createProject()")
        proj.title =  proj.experimentType.description + " " + randWords(3)
        proj.notes = randWords(15, sentence: true) + " " + randWords(10, sentence: true) + " " + randWords(20, sentence: true) + " " + randWords(17, sentence: true)
        let first = names[rand(0,names.count - 1)]
        let last = names[rand(0, names.count - 1)]
        proj.creator = User(first: first, last: last, username: first.lowercased() + last.lowercased() + Formatter.numFmtr(numIntDigits: 2).string(from: rand(10,99) as NSNumber)!)
        var reading: Reading
        var date: Date
        var dp: DataPoint
        var dps: [DataPoint] = []
        var idp: InstrumentDataPoint
        var val: Int
        var specificVal: Int
        var readingTypeInt: Int
        var tag: (ReadingType, Int)
        var millis: UInt32
        
        for _ in 0..<numReadings {
            
            val = rand(10, baselineVal)
            readingTypeInt = rand(0,ReadingType.allTypeArray.count - 1)
            date = proj.editDate!.addingTimeInterval(TimeInterval(rand(0,100_000)))
//            print("i:\(i) - val:\(val)- ReadingTypeInt:\(readingTypeInt)")
            for _ in 0..<rand(2,6) {
                specificVal = val + rand(-spread/2, spread/2)
                tag = (ReadingType.allTypeArray[readingTypeInt], readingTypeIndices[readingTypeInt])
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
            reading.typeDB = ReadingType.allTypeArray[readingTypeInt].rawValue
            reading.project = proj
            reading.title = randWords(2)
//            print("i:\(i) \(reading)")
            proj.addToReadingsDB(reading)
        }
//        print(proj)
        return proj
    }
    
    
    static let nonBlankTypes: [ReadingType] = [.control, .known, .standard, .unknown, .wildType, .mutant, .custom]
    static var lastValue: [ReadingType:Int] = [:]
    static var typeTagIndex: [ReadingType:Int] = [:]
    static var instrumentIndex = 0
    static var instrumentManagerBLE: CBInstrumentCentralManager!
    
    static let scheduleReadingTimer = { Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {_ in
        TestDataGenerator.sendIDP(isRepeat: Bool.init(TestDataGenerator.rand(0,1) as NSNumber))
    }) }
    static let scheduleBlankTimer = { Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {_ in
        TestDataGenerator.sendIDP(isRepeat: false, withTag: .blank)
        TestDataGenerator.sendIDP(isRepeat: true, withTag: .blank)
        TestDataGenerator.sendIDP(isRepeat: true, withTag: .blank)
    }) }
    
    
    static func setupBLESimulation() {
        instrumentManagerBLE.timeConverter = timeConverter
    }
    
    static func sendIDP(isRepeat: Bool = false, withTag tag: ReadingType? = nil) {
        
        let t = tag ?? nonBlankTypes[rand(0,nonBlankTypes.count - 1)]
        
        var vIsRepeat: Bool = isRepeat
        
        if let i = typeTagIndex[t] {
            if !vIsRepeat {
                typeTagIndex[t] = i + 1
            }
        } else {
            typeTagIndex[t] = 0
            vIsRepeat = false
        }
        
        let val: Int
        if t == .blank {
            val = 2800 + rand(-spread / 2, spread / 2)
        } else {
            if vIsRepeat {
                val = lastValue[t]! + rand(-spread / 2, spread / 2)
            } else {
                val = rand(0,2800)
                lastValue[t] = val
            }
        }
        
        let idp = InstrumentDataPoint(index: instrumentIndex, value: val, tag: (t,typeTagIndex[t]!), uuid: UUID(), timestamp: InstrumentTimeConverter.millis(fromDate: initialDate))
        instrumentIndex += 1
        
        instrumentManagerBLE.dataParser(instrumentManagerBLE.dataParser, didRecieveObject: idp, withTag: CBDataParser.ParsingTag.dataPoint, fromPeripheral: nil, fromCharachteristic: nil)
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
