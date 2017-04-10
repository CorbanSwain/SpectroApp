//
//  CBDataParser.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/24/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol CBDataParserDelegate: class {
    func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, withTag tag: CBDataParser.ParsingTag, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic)
    func dataParser(_ dataParser: CBDataParser, didBeginParsingObjectWithTag tag: CBDataParser.ParsingTag, FromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic)
}

class CBDataParser {
    
    enum ParseStatus {
        case calm
        case recievingTag
        case recievingJSON
    }
    
    enum ParsingTag: Character, CustomStringConvertible {
        case dataPoint = "P"
        case instrumentInfo = "I"
        case instrumentTime = "T"
        
        var description: String {
            switch self {
            case .dataPoint:
                return "an instrument data point"
            case .instrumentInfo:
                return "instrument information"
            case .instrumentTime:
                return "instrument time in ms"
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
        case .instrumentTime:
            return json["Millis"].uInt32Value
        }
    }
    
    init(withDelegate delegate: CBDataParserDelegate) {
        self.delegate = delegate
    }
    
    func parse(_ data: Data, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        guard let string = String(data: data, encoding: .utf8) else {
            print("BLE:_String could not be extracted from data.")
            return
        }
        for char in string.characters {
            // FIXME, need to handle potentially incomplete string i.e. "<T{.....}" where there is no closing char, '>'
            switch char {
            case openingChar:
                print("BLE:_JSON String has begun ...")
                jsonString = ""
                parseStatus = .recievingTag
            case closingChar:
                print("BLE:_JSON String has ended.")
//                print("BLE:_ --> \(jsonString)")
                parseStatus = .calm
                guard let object = parsedObject else {
                    print("BLE:_ERROR: Object could not be created from jsonString!")
                    return
                }
                delegate?.dataParser(self, didRecieveObject: object, withTag: tag!, fromPeripheral: peripheral, fromCharachteristic: charachteristic)
            default:
                switch parseStatus {
                case .calm:
                    print("BLE:_Recieving improperly formatted data string! --> | \(char) |")
                    break
                case .recievingTag:
                    tag = ParsingTag(rawValue: char)
                    parseStatus = .recievingJSON
                    guard let t = tag else {
                        //  Fix me
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
