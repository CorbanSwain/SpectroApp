//
//  Formatters.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation
import UIKit

class Formatter {
    static let monDayYr = dateFmtr("MMM dd, YYYY")
    static let monDayYrHrMin = dateFmtr("MMM dd, YYYY hh:mm a")
    static let hrMin = dateFmtr("hh:mm a")
    static let sorting = dateFmtr("YYYYMMddHHmm")
    
    static func dateFmtr(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    static func date(_ format: String,_ date: Date) -> String {
        return dateFmtr(format).string(from: date)
    }
    
    static let threeDecNum = numFmtr(numDecimals: 3)
    static let fourDigNum = numFmtr(numIntDigits: 4)
    static let twoDigNum = numFmtr(numIntDigits: 2)
    static let intNum = numFmtr(numIntDigits: 5, minIntDigits: 1)
    
    static func numFmtr(numDecimals: Int) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = numDecimals
        nf.maximumFractionDigits = numDecimals
        return nf
    }
    static func numFmtr(numIntDigits: Int, minIntDigits: Int? = nil) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .none
        nf.minimumIntegerDigits = minIntDigits ?? numIntDigits
        nf.maximumIntegerDigits = numIntDigits
        return nf
    }
}
