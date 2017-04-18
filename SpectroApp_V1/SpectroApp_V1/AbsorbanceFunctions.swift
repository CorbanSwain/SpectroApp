//
//  AbsorbanceKit.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import Darwin

extension UUID {
    init(stringOptional uuidStr: String?) {
        guard let str = uuidStr, let newID = UUID(uuidString: str) else {
            print("uuid passed is incomplete or nil \n\t↳UUID.init(stringOptional:)")
            self.init(uuid: UUID_NULL)
            return
        }
        self.init(uuid: newID.uuid)
    }
}

func getVals(fromPoints points: [DataPoint]) -> [CGFloat] {
    var vals: [CGFloat] = []
    for point in points {
        guard let v = point.measurementValue else {
            continue
        }
        vals.append(v)
    }
    return vals
}

func getVals(fromPoints points: Set<DataPoint>) -> Set<CGFloat> {
    var vals: Set<CGFloat> = []
    for point in points {
        guard let v = point.measurementValue else {
            continue
        }
        vals.insert(v)
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

func average(ofFloats floats: Set<CGFloat>) -> CGFloat? {
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

func average(ofPoints points: Set<DataPoint>) -> CGFloat? {
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

func stdev(ofFloats floats: Set<CGFloat>) -> CGFloat? {
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

func stdev(ofPoints points: Set<DataPoint>) -> CGFloat? {
    return stdev(ofFloats: getVals(fromPoints: points))
}

