//
//  AbsorbanceKit.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import Darwin

struct AbsorbanceKit {
    
    enum ExperimentType {
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
    }
    
    enum ReadingType: String {
        case control
        case standard
        case unknown
        case wildType
        case mutant
        case custom
    }
    
    enum Wavelength: Int {
        case _260 = 260 // nucleic acid
        case _280 = 280 // protein
        case _560 = 560 // cell density
        case _595 = 595 // bradford
    }
    
    public static func average(of points: [DataPoint]) -> CGFloat? {
        let count = points.count
        guard count > 0 else {
            return nil
        }
        var average: CGFloat = 0
        for point in points { average += point.value }
        return average / CGFloat(count)
    }
    
    public static func stdev(of points: [DataPoint]) -> CGFloat? {
        let count = points.count
        guard count > 1 else { return nil }
        guard let u = average(of: points) else { return nil }
        var sumsq: CGFloat = 0
        var diff: CGFloat
        for point in points {
            diff = point.value - u
            sumsq +=  diff * diff
        }
        return sqrt(sumsq / CGFloat(count - 1))
    }
}
