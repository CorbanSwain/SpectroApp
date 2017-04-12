//
//  InstrumentTimeConverter.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/6/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

class InstrumentTimeConverter {
    private var synchonizationDuple: (instrumentMillis: UInt32, centralDate: Date)
    
    private var turnOnDate: Date {
        return synchonizationDuple.centralDate.addingTimeInterval(intervalSinceOn(synchonizationDuple.instrumentMillis))
    }
    
    let intervalSinceOn: (UInt32) -> TimeInterval = {-(Double($0) / Double(1000))}
    
    
    init(instrumentMillis: UInt32, centralTime: Date) {
        synchonizationDuple = (instrumentMillis, centralTime)
    }
    
    convenience init(instrumentMillis: UInt32) {
        self.init(instrumentMillis: instrumentMillis, centralTime: Date())
    }
    
    func createDate(fromInstrumentMillis instrumentMillis: UInt32) -> Date {
        return turnOnDate.addingTimeInterval(-intervalSinceOn(instrumentMillis))
    }
    
    static func millis(fromDate date: Date) -> UInt32 {
        return UInt32(-date.timeIntervalSinceNow * 1000)
    }
    
}
