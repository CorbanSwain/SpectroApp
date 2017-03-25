//
//  CBDataParser.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/24/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

class CBDataParser {
    
    enum ParseStatus {
        case calm
        case recievingTag
        case recievingJSON
    }
    
    enum ParsingTag: Character, CustomStringConvertible {
        case dataPoint = "P"
        case instrumentInfo = "I"
        
        var description: String {
            switch self {
            case .dataPoint:
                return "an instrument data point"
            case .instrumentInfo:
                return "instrument information"
            }
        }
    }
    
    let openingChar: Character = "<"
    let closingChar: Character = ">"
    
    weak var delegate: CBDataParserDelegate?
    
    var parseStatus: ParseStatus = .calm
    
    var tag: ParsingTag? = nil
    
    var jsonString = ""
    
    var parsedObject: Any? {
        guard let t = tag else {
            return nil
        }
        
        let json = JSON(parseJSON: jsonString)
        
        switch t {
        case .dataPoint:
            return json.instrumentDataPointValue
        case .instrumentInfo:
            // FIX ME!!!
            return nil
        }
    }
    
    init(withDelegate delegate: CBDataParserDelegate) {
        self.delegate = delegate
    }
    
    func parse(_ data: Data, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        guard let string = String(data: data, encoding: .utf8) else {
            print("String could not be extracted from data.")
            return
        }
        for char in string.characters {
            switch char {
            case openingChar:
                print("JSON String has begun ...")
                jsonString = ""
                parseStatus = .recievingTag
            // FIX ME add timing structure to prevent canAppendChars from staying true indefinately...
            case closingChar:
                print("JSON String has ended.")
                parseStatus = .calm
                guard let object = parsedObject else {
                    print("ERROR: Object could not be created from jsonString!")
                    return
                }
                delegate?.dataParser(self, didRecieveObject: object, withTag: tag!, fromPeripheral: peripheral, fromCharachteristic: charachteristic)
                
            default:
                switch parseStatus {
                case .calm:
                    print("Recieving improperly formatted data string")
                    break
                case .recievingTag:
                    tag = ParsingTag(rawValue: char)
                    parseStatus = .recievingJSON
                    guard let t = tag else {
                        break
                    }
                    delegate?.dataParser(self, didBeginParsingObjectWithTag: t, FromPeripheral: peripheral, fromCharachteristic: charachteristic)
                    
                case .recievingJSON:
                    jsonString.append(char)
                    
                }
            }
        }
    }
    
}
