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
    
    var title: String? {
        get {
            return titleDB
        }
        set {
            titleDB = newValue
        }
    }
    
    var isCalibrationPoint: Bool {
        get {
            return isCalibrationPointDB
        } set {
            isCalibrationPointDB = newValue
        }
    }
    
    var wavelength: Wavelength {
        get {
            return Wavelength(rawValue: wavelengthDB) ?? .unknown
        }
        set {
            wavelengthDB = newValue.rawValue
        }
    }
    
    var baselineValue: Int {
        get {
            return Int(baselineValueDB)
        } set {
            baselineValueDB = Int32(newValue)
        }
    }
    
    var measurementValue: CGFloat? {
        get {
            if let manualVal = manualValue, manualVal.isSet {
                return manualVal.measurementValue
            } else if let v = instrumentDataPoint?.measurementValue {
                return CGFloat(v) / CGFloat(baselineValue)
            } else {
                return nil
            }
        } set {
            manualValue = ManualValue()
            if let v = newValue  {
                manualValue?.measurementValue = CGFloat(v)
            } else {
                manualValue?.measurementValue = 0
                manualValue?.isSet = false
            }
        }
    }
    
    var timestamp: Date? {
        get {
            guard let tstamp = timestampDB as Date? else {
                return nil
            }
            return tstamp
        } set {
            timestampDB = newValue as NSDate?
        }
    }
    
    convenience init() {
        self.init(context: AppDelegate.viewContext)
        timestamp = Date()
    }
    
    convenience init(fromIDP idp: InstrumentDataPoint, usingTimeConverter timeConverter: InstrumentTimeConverter) {
        self.init()
        instrumentDataPoint = idp
        idp.dataPoint = self
        title = "\(idp.tag.type.description)-\(idp.tag.index)"
        timestamp = timeConverter.createDate(fromInstrumentMillis: idp.instrumentMillis)
    }
}
