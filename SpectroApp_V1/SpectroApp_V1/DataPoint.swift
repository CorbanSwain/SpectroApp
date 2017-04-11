//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

class DataPoint: AbsorbanceObject {
    
    var pointValue: CGFloat? {
        get {
            if let mv = manualValue, mv.isSet {
                return CGFloat(mv.theValue)
            } else if let v = instrumentDataPoint?.measurementValue {
                return CGFloat(v) / CGFloat(baselineValue)
            } else {
                return nil
            }
        } set {
            if let v = newValue  {
                manualValue?.theValue = Float(v)
            } else {
                manualValue = nil
            }
        }
    }
    
    init() {
        super.init(entity: InstrumentDataPoint.entity(), insertInto: AppDelegate.viewContext)
        timestamp = NSDate()
        uuid = UUID()
    }
    
    convenience init(fromIDP idp: InstrumentDataPoint, usingTimeConverter timeConverter: InstrumentTimeConverter) {
        self.init()
        instrumentDataPoint = idp
        timestamp = timeConverter.createDate(fromInstrumentMillis: idp.instrumentMillis) as NSDate
        uuid = idp.uuid
    }
}
