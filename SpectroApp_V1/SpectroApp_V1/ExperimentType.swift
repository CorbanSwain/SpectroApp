//
//  ExperimentType.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum ExperimentType: UInt16, CustomStringConvertible  {
    case bradford = 0
    case cellDensity = 1
    case nuecleicAcid = 2
    
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
    
    var description: String {
        switch self {
        case .bradford:
            return "Bradford Assay"
        case .cellDensity:
            return "Cell Density"
        case .nuecleicAcid:
            return "Nuecleic Acid Concentration"
        }
    }
}
