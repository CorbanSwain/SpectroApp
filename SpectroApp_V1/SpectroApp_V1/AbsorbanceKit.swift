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
        case bradford, cellDensity, nuecleicAcid
        var wavelength: String {
            switch self {
            case .bradford:
                return "560"
            case .cellDensity:
                return "560"
            case .nuecleicAcid:
                return "260 & 280"
            }
        }
    }
    
    enum ReadingType {
        case control, unknown
    }
    
    public static func average(of points: Set<DataPoint>) -> CGFloat? {
        let count = points.count
        guard count > 0 else {
            return nil
        }
        var average: CGFloat = 0
        for point in points { average += point.value }
        return average / CGFloat(count)
    }
    
    public static func stdev(of points: Set<DataPoint>) -> CGFloat? {
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
