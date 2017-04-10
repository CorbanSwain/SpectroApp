//
//  Wavelength.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import Foundation

enum Wavelength: UInt16 {
    case _260 = 0
    case _280 = 1
    case _560 = 2
    case _595 = 3
    
    var nanometers: Int {
        switch self {
        case ._260: return 260
        case ._280: return 280
        case ._560: return 560
        case ._595: return 595
        }
    }
}
