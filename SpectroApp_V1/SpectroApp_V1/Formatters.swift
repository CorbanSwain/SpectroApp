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
    static var noDateStr = "[no date]"
    
    static let monDayYrRetHrMin = dateFmtr("MMM dd, YYYY\nhh:mm a")
    static let monDayYr = dateFmtr("MMM dd, YYYY")
    static let monDayYrHrMin = dateFmtr("MMM dd, YYYY hh:mm a")
    static let monDayYrExcel = dateFmtr("MM/dd/YYYY")
    static let monDayYrHrMinExcel = dateFmtr("MM/dd/YYYY HH:mm")
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
    
    static let tenDecNum = numFmtr(numDecimals: 10)
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
    
    static let tabularFiguresDictionary = [
        UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
        UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector,
        ]
    
    static let tabularFiguresAttributes = [
        UIFontDescriptorFeatureSettingsAttribute: [ tabularFiguresDictionary ],
        ]
    
}

extension DateFormatter {
    func string(fromOptional date: Date?) -> String? {
        if let d = date {
            return string(from: d)
        } else {
            return nil
        }
    }
}

extension NumberFormatter {
    func string(fromOptional num: NSNumber?) -> String? {
        if let n = num {
            return  string(from: n)
        } else {
            return nil
        }
    }
}
