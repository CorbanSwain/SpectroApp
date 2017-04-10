//
//  ReadingType.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum ReadingType: UInt16, CustomStringConvertible {
    case control = 3
    case standard = 6
    case unknown = 7
    case known = 10
    case wildType = 4
    case mutant = 9
    case custom = 5
    case noType = 0
    
    var stringValue: String {
        switch self {
        case .control: return "control"
        case .known: return "known"
        case .standard: return "standard"
        case .unknown: return "unknown"
        case .wildType: return "wildType"
        case .mutant: return "mutant"
        case .custom: return "custom"
        case .noType: return "[no type]"
        }
    }
    
    static var allTypes: Set<ReadingType> {
        return [.control, .standard, .unknown, .wildType, .mutant, .custom]
    }
    
    init(fromString string: String) {
        for type in ReadingType.allTypes {
            if type.stringValue == string {
                self = type
            }
        }
        self = .noType
    }
    
    var description: String {
        switch self {
        case .wildType:
            return "Wild Type"
        default:
            return self.stringValue.capitalized(with: nil)
        }
    }
}
