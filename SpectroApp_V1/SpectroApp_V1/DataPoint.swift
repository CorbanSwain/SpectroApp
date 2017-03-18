//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

public let dataPointJSONExample = JSON(data: "{\"Index\":\"4\", \"Value\":\"2776\", \"Tag\":\"control\", \"TagNumber\":\"2\", \"ID\":\"24566781\"}".data(using: .utf8)!)

struct DataPoint {
    
    var dataPointID: String
    
    var value: CGFloat
    var timeStamp: Date
    var pointLabel: String
    var reading: Reading
    var instrumentUUID: UUID
    
    var instrumentDataPoint: InstrumentDataPoint
}

struct InstrumentDataPoint: CustomStringConvertible {
    var index: Int
    var value: Int
    var tag: (type: ReadingType, index: Int)
    
    var description: String {
        if tag.type == .noType {
            return "<Data Point #\(index), [no tag] : \(value)>"
        }
        else {
            return "<Data Point #\(index), \(tag.type)-\(tag.index) : \(value)>"
        }
    }
}

extension JSON {
    var instrumentDataPointValue: InstrumentDataPoint {
        let index = self["Index"].intValue
        let value = self["Value"].intValue
        let tagNum = self["TagNumber"].intValue
        let tagID = self["Tag"].stringValue
        let tagType = ReadingType.get(fromString: tagID)
        return InstrumentDataPoint(index: index, value: value, tag: (tagType, tagNum))
    }
}
