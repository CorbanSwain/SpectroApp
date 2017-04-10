//
//  AbsorbanceKit.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import Darwin

enum ExperimentType: String, CustomStringConvertible  {
   //FIXME
    case bradford
    case cellDensity
    case nuecleicAcid
    var wavelength: Wavelength {
        switch self {
        case .bradford:
            return ._595
        case .cellDensity:
            return ._560
        case .nuecleicAcid:
            return ._280
        }
    }
    
    var description: String { return self.rawValue }
}

enum ReadingType: String, CustomStringConvertible {
    case control
    case standard
    case unknown
    case wildType
    case mutant
    case custom
    case noType
    
    static var allTypes: Set<ReadingType> {
        return [.control, .standard, .unknown, .wildType, .mutant, .custom]
    }
    
    init(fromString string: String) {
        if let t = ReadingType(rawValue: string) {
            self = t
        } else {
            self = .noType
        }
    }
    
    var description: String {
        switch self {
        case .wildType:
            return "Wild_Type"
        case .noType:
            return "[no type]"
        default:
            return self.rawValue.capitalized(with: nil)
        }
    }
}

enum Wavelength: Int {
    case _260 = 260 // nucleic acid
    case _280 = 280 // protein
    case _560 = 560 // cell density
    case _595 = 595 // bradford
}


func getVals(fromPoints points: [DataPoint]) -> [CGFloat] {
    var vals: [CGFloat] = []
    for point in points {
        guard let v = point.value else {
            continue
        }
        vals.append(v)
    }
    return vals
}


func average(ofFloats floats: [CGFloat]) -> CGFloat? {
    guard floats.count > 1 else {
        return nil
    }
    var sum: CGFloat = 0
    for x in floats {
        sum += x
    }
    return sum / CGFloat(floats.count)
}

func average(ofPoints points: [DataPoint]) -> CGFloat? {
    return average(ofFloats: getVals(fromPoints: points))
}

func stdev(ofFloats floats: [CGFloat]) -> CGFloat? {
    guard floats.count > 1 else {
        return nil
    }
    let u = average(ofFloats: floats)!
    var sumsq: CGFloat = 0
    var diff: CGFloat
    for x in floats {
        diff = x - u
        sumsq +=  diff * diff
    }
    return sqrt(sumsq / CGFloat(floats.count - 1))
}

func stdev(ofPoints points: [DataPoint]) -> CGFloat? {
    return stdev(ofFloats: getVals(fromPoints: points))
}

