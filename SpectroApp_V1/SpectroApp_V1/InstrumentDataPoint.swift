//
//  InstrumentDataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/25/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

/// An example JSON string to show the format for measuments sent by a connected instrument
public let instrumentDP_StringExample = "{\"Index\":\"4\", \"Value\":\"2776\", \"Tag\":\"control\", \"TagNumber\":\"2\", \"Identifier\":\"24566781\", \"Timestamp\":\"22231\"}"
public let instrumentDP_JSONExample = JSON(parseJSON: instrumentDP_StringExample)

struct InstrumentDataPoint: CustomStringConvertible, Hashable {
    static let instrumentDP_ObjectExample = instrumentDP_JSONExample.instrumentDataPointValue
    
    var index: Int
    var value: Int
    var tag: (type: ReadingType, index: Int)
    var identifier: UUID
    var timestamp: UInt32
    var hashValue: Int { return identifier.hashValue }
    
    var description: String {
        if tag.type == .noType {
            return "Data Point <Index: \(index), Value: \(value), Tagged: [no tag], ID: \(identifier), Timestamp: \(timestamp) ms>"
        }
        else {
            return "Data Point <Index: \(index), Value: \(value), Tagged: \(tag.type)-\(tag.index), ID: \(identifier), Timestamp: \(timestamp) ms>"
        }
    }
    
    static func ==(lhs: InstrumentDataPoint, rhs: InstrumentDataPoint) -> Bool {
        return lhs.identifier == rhs.identifier
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
        return InstrumentDataPoint(index: index, value: value, tag: (tagType, tagNum), identifier: ID, timestamp: timestamp)
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
