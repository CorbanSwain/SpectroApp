//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit


struct DataPoint {
    
    let identifier: UUID
    var readingID: UUID?
    var isCalibrationPoint: Bool = false
    
    var value: CGFloat? {
        get {
            if let v = manualValue {
                return v
            } else if let v = instrumentDataPoint?.value, let b = instrumentBaselineValue {
                return CGFloat(v) / CGFloat(b)
            } else {
                return nil
            }
        } set {
            if let v = newValue  {
                manualValue = v
            } else {
                manualValue = nil
            }
        }
    }
    
    var manualValue: CGFloat?
    var timestamp: Date
    var pointLabel: String?
    var instrumentUUID: UUID?
    
    var instrumentDataPoint: InstrumentDataPoint?
    var instrumentBaselineValue: Int?
    
    init() {
        timestamp = Date()
        identifier = UUID()
    }
    
    init(fromIDP idp: InstrumentDataPoint, usingTimeConverter timeConverter: InstrumentTimeConverter) {
        instrumentDataPoint = idp
        timestamp = timeConverter.createDate(fromInstrumentMillis: idp.timestamp)
        identifier = idp.uuid
    }
}
