//
//  ReadingType.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum ReadingType: Int16, CustomStringConvertible {
    static var numTypes = 8
    
    case noType = 0
    
    case control = 101 // 1
    case standard = 102// 2
    
    case unknown = 201 //3
    case known = 202   //4
    
    case wildType = 301//5
    case mutant = 302  //6
    
    case custom = 401 //7
    
    case blank = 901 //8
    
    private var stringValue: String {
        switch self {
        case .control: return "control"
        case .known: return "known"
        case .standard: return "standard"
        case .unknown: return "unknown"
        case .wildType: return "wildType"
        case .mutant: return "mutant"
        case .custom: return "custom"
        case .noType: return "[no type]"
        case .blank: return "blank"
        }
    }
    
    static var allTypeArray: [ReadingType] {
        return [.control, .known, .standard, .unknown, .wildType, .mutant, .custom, .blank]
    }
    
    static var allTypes: Set<ReadingType> {
        return [.control, .known, .standard, .unknown, .wildType, .mutant, .custom, .blank]
    }
    
    init(fromString string: String) {
        for type in ReadingType.allTypes {
//            print("\(string) == \(type.stringValue) : \(type.stringValue == string)")
            if type.stringValue == string {
                self = type
                return
            }
        }
        self = .noType
    }
    
    var description: String {
        switch self {
        case .wildType:
            return "Wild Type"
        case .noType:
            return self.stringValue
        default:
            return self.stringValue.capitalized(with: nil)
        }
    }

}
