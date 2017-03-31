//
//  Plot.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/31/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation
import UIKit

enum PlotType {
    case barPlot
    case linearReg
    case timecourse
}

class PlotModel {
    
    var plotType: PlotType = .barPlot
    var title: String = "foo"
    // when created
    var readings: [Reading] = []
    // project metadata
    
}

class PlotView: UIView {
    
}
