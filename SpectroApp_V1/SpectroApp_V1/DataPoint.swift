//
//  DataPoint.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

@objc(DataPoint)
class DataPoint: AbsorbanceObject {
    
    static var entityDescr: NSEntityDescription { return NSEntityDescription.entity(forEntityName: "DataPoint", in: AppDelegate.viewContext)! }
    
    var baseline: Int {
        get {
            return Int(baselineValue)
        } set {
            baselineValue = Int32(newValue)
        }
    }
    
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
            manualValue = ManualValue()
            if let v = newValue  {
                manualValue?.theValue = Float(v)
            } else {
                manualValue?.theValue = 0
                manualValue?.isSet = false
            }
        }
    }
    
    convenience init(fromIDP idp: InstrumentDataPoint, usingTimeConverter timeConverter: InstrumentTimeConverter) {
        // self.init(entity: DataPoint.entityDescr, insertInto: AppDelegate.viewContext)
        self.init(context: AppDelegate.viewContext)
        instrumentDataPoint = idp
        idp.dataPoint = self
        timestamp = timeConverter.createDate(fromInstrumentMillis: idp.instrumentMillis) as NSDate
    }
}
