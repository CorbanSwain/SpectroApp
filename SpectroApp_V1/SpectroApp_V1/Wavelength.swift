//
//  Wavelength.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum Wavelength: Int16 {
    case unknown = 0
    case _260 = 1
    case _280 = 2
    case _560 = 3
    case _595 = 4
    
    var nanometers: Int? {
        switch self {
        case .unknown: return nil
        case ._260: return 260
        case ._280: return 280
        case ._560: return 560
        case ._595: return 595
        }
    }
}
