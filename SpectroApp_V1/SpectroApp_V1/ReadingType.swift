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
    
    case control = 1
    case standard = 2
    case unknown = 3
    case known = 4
    case wildType = 5
    case mutant = 6
    case custom = 7
    case noType = 0
    
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
        case .noType:
            return self.stringValue
        default:
            return self.stringValue.capitalized(with: nil)
        }
    }

}
