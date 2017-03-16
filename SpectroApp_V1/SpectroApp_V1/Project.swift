//
//  Project.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

struct Project {
    var readings: [Reading]
    var title: String
    var timeStamp: Date
    var experimentType: AbsorbanceKit.ExperimentType
}
