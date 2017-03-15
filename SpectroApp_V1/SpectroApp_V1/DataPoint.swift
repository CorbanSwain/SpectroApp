//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

struct DataPoint: Hashable {
    
    var value: CGFloat
    var timeStamp: Date
    var measurementID: String
    var pointLabel: String
    var hashValue: Int
    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        return lhs.measurementID == rhs.measurementID
    }
    
}
