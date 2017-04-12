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

class InstrumentDataPoint: AbsorbanceObject {
    
    static let instrumentDP_ObjectExample = instrumentDP_JSONExample.instrumentDataPointValue
    
    var tag: (type: ReadingType, index: Int32) {
        get {
            return (ReadingType(rawValue: self.tagTypeInt) ?? .noType, tagIndex)
        } set {
            tagTypeInt = newValue.type.rawValue
            tagIndex = newValue.index
        }
    }

    var instrumentMillis: UInt32 {
        get {
            return UInt32(instrumentTime)
        } set {
            instrumentTime = Int64(newValue)
        }
    }
    
    var customDescription: String {
        if tag.type == .noType {
            return "Data Point <Index: \(pointIndex), Value: \(measurementValue), Tagged: [no tag], ID: \(uuid), Timestamp: \(instrumentTime) ms>"
        }
        else {
            return "Data Point <Index: \(pointIndex), Value: \(measurementValue), Tagged: \(tag.type)-\(tag.index), ID: \(uuid), Timestamp: \(instrumentTime) ms>"
        }
    }
    
    init() {
        super.init(entity: InstrumentDataPoint.entity(), insertInto: AppDelegate.viewContext)
    }
    
    convenience init(index: Int, value: Int, tag: (ReadingType, Int), uuid: UUID, timestamp: UInt32) {
        self.init()
        self.pointIndex = Int32(index)
        self.measurementValue = Int32(value)
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
