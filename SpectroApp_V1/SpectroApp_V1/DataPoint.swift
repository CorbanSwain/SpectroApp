//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit


struct DataPoint {
    
    var dataPointID: String
    
    var value: CGFloat
    var timeStamp: Date
    var pointLabel: String
    var reading: Reading
    var instrumentUUID: UUID
    
    var instrumentDataPoint: InstrumentDataPoint
}
