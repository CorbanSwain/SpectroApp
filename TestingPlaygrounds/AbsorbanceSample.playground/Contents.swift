//: Playground - noun: a place where people can play

import UIKit

class AbsorbanceSample {
    
    enum SampleType {
        case bradford, cellDensity, nuecleicAcid
        
        var wavelength: Int {
            switch self {
            case .bradford:
                break
                
            case .cellDensity:
                break
                
            case .nuecleicAcid:
                break
            }
            
            return 560
        }
    }
    
    var sampleName: String
    var sampleType: SampleType
    var timestamp: CFTimeInterval
    var blankStatus: Bool
    var hasRepeats: Bool {
        get {
            
        }
    }
    var repeats: [CGFloat]
    var absorbanceValue: CGFloat {
        get {
            AbsorbanceBundle.average(of: repeats)
        }
    }
}


class AbsorbanceProject {
    
    var samples: [AbsorbanceSample]
    var title: String
    var timeStamp: CFTimeInterval
    
}

class AbsorbanceBundle {
    public static func average(of array: [CGFloat]) -> CGFloat {
        var average: CGFloat = 0
        
        for element in array {
            average += element
        }
        
        return average / CGFloat(array.count)
    }
}

