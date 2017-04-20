//
//  DateSection.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum DateSection: Int16 {
    case today = 0
    case yesterday
    case thisWeek
//    case lastWeek
    case thisMonth
    case lastMonth
    case twoMonthsAgo
    case threeMonthsAgo
    case thisYear
    case lastYear
    case twoYearsAgo
    case older
    case undated
    
    var date: Date {
        let date = Date()
        switch self {
        case .today:
            let components1 = Calendar.current.dateComponents([.year, .month, .weekOfYear, .weekOfMonth, .day], from: date)
            return Calendar.current.date(from: components1)!
        case .yesterday:
            return DateSection.adjustDate(date: DateSection.today.date, y: 0, mo: 0, d: -1)
        case .thisWeek:
            let components2 = Calendar.current.dateComponents([.year, .month, .weekOfYear, .weekOfMonth], from: date)
            return DateSection.adjustDate(date: Calendar.current.date(from: components2)!, y: 0, mo: 0, d: 0, w: 2)
//        case .lastWeek:
//            return DateSection.adjustDate(date: DateSection.thisWeek.date, y: 0, mo: 0, d: 0, w: -1)
        case .thisMonth:
            let components3 = Calendar.current.dateComponents([.year, .month], from: date)
            return Calendar.current.date(from: components3)!
        case .lastMonth:
            return DateSection.adjustDate(date: DateSection.thisMonth.date, y: 0, mo: -1, d: 0)
        case .twoMonthsAgo:
            return DateSection.adjustDate(date: DateSection.lastMonth.date, y: 0, mo: -1, d: 0)
        case .threeMonthsAgo:
            return DateSection.adjustDate(date: DateSection.twoMonthsAgo.date, y: 0, mo: -1, d: 0)
        case .thisYear:
            let components4 = Calendar.current.dateComponents([.year], from: date)
            return Calendar.current.date(from: components4)!
        case .lastYear:
            return DateSection.adjustDate(date: DateSection.thisYear.date, y: -1, mo: 0, d: 0)
        case .twoYearsAgo:
            return DateSection.adjustDate(date: DateSection.lastYear.date, y: -1, mo: 0, d: 0)
        default:
            return Date.init(timeIntervalSince1970: 0)
            
            
        }
    }
    
    static var sectionArray: [DateSection] { return [.today, .yesterday, .thisWeek, /*.lastWeek,*/ .thisMonth, .lastMonth, .twoMonthsAgo, .threeMonthsAgo, .thisYear, .lastYear, .twoYearsAgo, .older] }
    
    static var dateArray: [Date] {
        var dates: [Date] = []
        for section in sectionArray {
            dates.append(section.date)
        }
        return dates
    }
    
    
    var header: String {
        switch self {
        case .today:
            return "Today"
        case .yesterday:
            return "Yesterday"
        case .thisWeek:
            return "This Week"
//        case .lastWeek:
//            return"Last Week"
        case .thisMonth:
            return "This Month"
        case .lastMonth, .twoMonthsAgo, .threeMonthsAgo:
            return Formatter.dateFmtr("MMMM YYYY").string(from: date)
        case .thisYear, .lastYear, .twoYearsAgo:
            return Formatter.dateFmtr("YYYY").string(from: date)
        case .older:
            return "Older"
        case .undated:
            return "Undated"
        }
        
    }
    
    static func adjustDate(date: Date, y: Int, mo: Int, d: Int, w: Int = 0) -> Date {
        var newDate = date
        newDate = Calendar.current.date(byAdding: .day, value: d, to: newDate)!
        newDate = Calendar.current.date(byAdding: .month, value: mo, to: newDate)!
        newDate = Calendar.current.date(byAdding: .year, value: y, to: newDate)!
        newDate = Calendar.current.date(byAdding: .weekOfYear, value: w, to: newDate)!
        return newDate
    }
    
    static func setDate(date: Date, y: Int?, mo: Int?, d: Int?) -> Date {
        var newDate = date
        if let d = d {
            newDate = Calendar.current.date(bySetting: .day, value: d, of: newDate)!
        }
        if let mo = mo {
            newDate = Calendar.current.date(bySetting: .month, value: mo, of: newDate)!
        }
        if let y = y {
            newDate = Calendar.current.date(bySetting: .year, value: y, of: newDate)!
        }
        return newDate
    }
    
    
    func compare(_ other: DateSection) -> ComparisonResult {
        let v1 = rawValue
        let v2 = other.rawValue
        if v1 < v2 {
            return .orderedAscending
        } else if v2 < v1 {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}
