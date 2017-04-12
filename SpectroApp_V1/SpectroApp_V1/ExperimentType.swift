//
//  ExperimentType.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum ExperimentType: Int16, CustomStringConvertible  {
    case noType = 0
    case bradford = 1
    case cellDensity = 2
    case nuecleicAcid = 3
    
    var wavelength: Wavelength {
        switch self {
        case .bradford:
            return ._595
        case .cellDensity:
            return ._560
        case .nuecleicAcid:
            return ._280
        case .noType:
            return .unknown
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
        case .noType:
            return "Unknown Exp."
        }
    }
}
