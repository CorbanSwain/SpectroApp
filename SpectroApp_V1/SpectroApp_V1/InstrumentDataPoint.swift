//
//  InstrumentDataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/25/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation
import CoreData

// An example JSON string to show the format for measuments sent by a connected instrument
public let instrumentDP_StringExample = "{\"Index\":\"4\", \"Value\":\"2776\", \"Tag\":\"control\", \"TagNumber\":\"2\", \"Identifier\":\"24566781\", \"Timestamp\":\"2223145\"}"
public let instrumentDP_JSONExample = JSON(parseJSON: instrumentDP_StringExample)

@objc(InstrumentDataPoint)
class InstrumentDataPoint: AbsorbanceObject {
    
    static let instrumentDP_ObjectExample = instrumentDP_JSONExample.instrumentDataPointValue
    
    static var entityDescr: NSEntityDescription { return NSEntityDescription.entity(forEntityName: "InstrumentDataPoint", in: AppDelegate.viewContext)! }
    
    var pointIndex: Int {
        get { return Int(pointIndexDB) }
        set { pointIndexDB = Int32(newValue) }
    }
    
    var tag: (type: ReadingType, index: Int) {
        get {
            return (ReadingType(rawValue: self.tagTypeDB) ?? .noType, Int(tagIndexDB))
        } set {
            tagTypeDB = newValue.type.rawValue
            tagIndexDB = Int32(newValue.index)
        }
    }
    
    var instrumentID: UUID {
        get {
            return UUID(stringOptional: instrumentIDDB)
        }
        set {
            instrumentIDDB = newValue.uuidString
        }
    }
    
    var connectionSessionID: UUID {
        get {
            return UUID(stringOptional: connectionSessionIDDB)
        } set {
            connectionSessionIDDB = newValue.uuidString
        }
    }
    
    var instrumentMillis: UInt32 {
        get {
            return UInt32(instrumentMillisDB)
        } set {
            instrumentMillisDB = Int64(newValue)
        }
    }
    
    var uuid: UUID {
        get {
            return UUID(stringOptional: uuidDB)
        } set {
            uuidDB = newValue.uuidString
        }
    }
    
    var customDescription: String {
        return "Instr.DataPoint <Index: \(pointIndex), Value: \(measurementValue), Tagged: \(tag.type)-\(tag.index), ID: \(uuid), Timestamp: \(instrumentMillis) ms>"
    }
    
    var measurementValue: Int {
        get {
            return Int(measurementValueDB)
        } set {
            measurementValueDB = Int32(newValue)
        }
    }
    
    convenience init(index: Int, value: Int, tag: (ReadingType, Int), uuid: UUID, timestamp: UInt32) {
        self.init(context: AppDelegate.viewContext)
        self.tag = tag
        self.pointIndex = index
        self.measurementValue = value
        self.uuid = uuid
        self.instrumentMillis = timestamp
    }
}

// add JSON support for instrument data points
extension JSON {
    var instrumentDataPointValue: InstrumentDataPoint {
        let index = self["Index"].intValue
        let value = self["Value"].intValue
        let tagNum = self["TagNumber"].intValue
        let tagID = self["Tag"].stringValue
        let ID = self["Identifier"].uuidValue
        let timestamp = self["Timestamp"].uInt32Value
        let tagType = ReadingType(fromString: tagID)
        return InstrumentDataPoint(index: index, value: value, tag: (tagType, tagNum), uuid: ID, timestamp: timestamp)
    }
}

// add JSON support for UUIDs
extension JSON {
    public var uuid: UUID? {
        get {
            guard let s = string else { return nil }
            return UUID(uuidString: s)
        }
        set {
            self.object = newValue?.uuidString ?? NSNull()
        }
    }
    
    public var uuidValue: UUID {
        get {
            return uuid ?? UUID(uuid: UUID_NULL)
        }
        set {
            self.object = newValue.uuidString
        }
    }
    
}
