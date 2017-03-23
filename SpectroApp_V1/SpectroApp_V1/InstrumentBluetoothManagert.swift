//
//  InstrumentBluetoothManager.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

public let instrumentDPStringExample = JSON(data: "<P{\"Index\":\"4\", \"Value\":\"2776\", \"Tag\":\"control\", \"TagNumber\":\"2\", \"Identifier\":\"24566781\"}>".data(using: .utf8)!)

fileprivate let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
fileprivate let uartTXCharID = CBUUID(string:    "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
fileprivate let uartRXCharID = CBUUID(string:    "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
fileprivate let legoSpecID = UUID(uuidString: "EF520BC5-9EF2-4801-B395-DA0D146A4B65")


protocol CBInstrumentCentralManagerReporter: class {
    func display(_ status: InstrumentStatus, message: String?)
}

class CBInstrumentCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBDataParserDelegate, InstrummentSettingsViewControllerDelegate {
    
    let secondsToScanForPeripherals: TimeInterval = 20
    let secondsToWaitToTurnOn: TimeInterval = 3
    
    var centralManager: CBCentralManager!
    var dataParser: CBDataParser!
    var statusReporters: [CBInstrumentCentralManagerReporter] = []
    
    private let bleQueue = DispatchQueue.init(label: "bleQueue", qos: .utility)
    
    var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    
    var requiredServices = [uartServiceUUID]
    var rememberedPeripheralUUIDs = [legoSpecID]
    
    /// The peripheral currently connected to the device
    var connectedPeripheral: CBPeripheral? {
        willSet {
            guard let peripheral = connectedPeripheral else { return }
            if newValue == nil {
                discoveredPeripherals[peripheral.identifier] = nil
            }
        }
    }
    
    var status: (status: InstrumentStatus, message: String?) = (.busy, "Initializing…") {
        didSet { echoStatus() }
    }
    
    init(withReporter reporter: CBInstrumentCentralManagerReporter) {
        super.init()
        statusReporters.append(reporter)
        centralManager = CBCentralManager(delegate: self, queue: bleQueue)
        dataParser = CBDataParser(withDelegate: self)
    }
    
    func isOn() -> Bool {
        if centralManager.state == .poweredOn { return true }
        else { return false }
    }
    
    internal func rescanForDevices() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
        scanForPeripherals(withServices: requiredServices)
    }
    
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]? = nil) {
        let uuids = serviceUUIDs ?? requiredServices
        status = (.busy, "Checking if Bluetooth is on … ")
        bleQueue.async {
            let startTime = Date()
            while !self.isOn() && startTime.timeIntervalSinceNow > -self.secondsToWaitToTurnOn { }
            guard self.isOn() else {
                print("time up!, BLE not powered on, scan again after turning bluetooth on")
                self.status =  (.warning, "Bluetooth off, please turn on.")
                return
            }
            print("BLE On!, scanning for peripherals")
            DispatchQueue.main.async {
                self.status = (.busy, "Scanning for avalible instruments … ")
                self.centralManager.scanForPeripherals(withServices: uuids, options: nil)
                Timer.scheduledTimer(timeInterval: self.secondsToScanForPeripherals, target: self, selector: #selector(self.stopScanningForPeripherals), userInfo: nil, repeats: false)
            }
        }
    }
 
    func stopScanningForPeripherals() {
        guard centralManager.isScanning else {
            return
        }
        centralManager.stopScan()
        status = (.warning, "Could not find any instruments.")
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Core Bluetooth Central Manager state changed!")
        if isOn() {
            scanForPeripherals(withServices: requiredServices)
        } else {
            discoveredPeripherals = [:]
            status = (.warning, "Bluetooth off, please turn on.")
        }
        return
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let id = peripheral.identifier
        guard discoveredPeripherals[id] == nil && connectedPeripheral?.identifier != id else {
            print("peripherial already found")
            return
        }
        print("new perepherial found!")
        discoveredPeripherals[id] = peripheral
        
        if rememberedPeripheralUUIDs.contains(where: { $0 == id }) && connectedPeripheral == nil {
            print("A known instrument was found!")
            centralManager.stopScan()
            centralManager.connect(peripheral)
            status.message = "Connecting to instrument …"
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to a peripheral")
        status = (.warning, "Could not connect to instrument.")
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected!")
        connectedPeripheral = nil
        status = (.warning, "Instrument disconected.")
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scanForPeripherals), userInfo: nil, repeats: false)
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to a peripheral!")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([uartServiceUUID])
        print("searcing for services....")
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services,
            services.count > 0 && error == nil else {
                
            print("ERROR: no services found. \(error?.localizedDescription ?? "")")
            status = (.warning, "Instrument configured incorrectly. \(error?.localizedDescription ?? "")")
            return
        }
        print("Found a Service!")
  
        for service in services {
            if service.uuid == uartServiceUUID {
                print("sucessfully connected to UART service")
                peripheral.discoverCharacteristics([uartRXCharID], for: service)
                print("attemting to discover charachteristics …")
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let charachteristics = service.characteristics,
            charachteristics.count > 0 && error == nil else {
                
            print("ERROR: No charachteristics found. \(error?.localizedDescription ?? "")")
            status = (.warning, "Instrument configured incorrectly. \(error?.localizedDescription ?? "")")
            return
        }
        
        print("\(charachteristics.count) charachteristic(s) found!")
        status = (.busy, "Subscibing to instrument data …")
        
        for c in charachteristics {
            switch c.uuid {
            case uartRXCharID:
                print("Sucessfully found UART RX charachteristic...subscribing")
                peripheral.setNotifyValue(true, for: c)
                status = (.good, "Connected to instrument, waiting for incoming data.")
                
            default:
                break
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let data = characteristic.value else {
            print("Charachteristic's value updated, but no data could be extracted.")
            return
        }
        dataParser.parse(data, fromPeripheral: peripheral, fromCharachteristic: characteristic)
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didRecieveDataString string: String, fromCharachteristic characteristic: CBCharacteristic) {
        let instrumentDP = JSON(parseJSON: string).instrumentDataPointValue
        print("Recieved: \(instrumentDP)")
        
    }
    
    internal func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        switch parsedObject {
        case let instrumentDP as InstrumentDataPoint:
            print("Just got a data point!\n    --> \(instrumentDP)")
        default:
            print("Recieved an object, but it was of an unknown type.")
            break
        }
    }
    
    func addReporter(_ newReporter: CBInstrumentCentralManagerReporter) {
        statusReporters.append(newReporter)
        newReporter.display(status.status, message: status.message )
    }
    
    func popReporter() {
        statusReporters.removeLast()
    }
    
    func echoStatus() {
        for reporter in statusReporters {
            reporter.display(status.status, message: status.message)
        }
    }
    
}


protocol CBDataParserDelegate: class {
    func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic)
}


class CBDataParser {
    
    enum ParseStatus {
        case calm
        case recievingTag
        case recievingJSON
    }
    
    enum ParsingTag: Character {
        case dataPoint = "P"
        case instrumentInfo = "I"
    }
    
    let openingChar: Character = "<"
    let closingChar: Character = "<"
    
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
                jsonString = ""
                parseStatus = .recievingTag
                // FIX ME add timing structure to prevent canAppendChars from staying true indefinately...
            case closingChar:
                parseStatus = .calm
                guard let object = parsedObject else {
                    print("ERROR: Object could not be created from jsonString!")
                    return
                }
                delegate?.dataParser(self, didRecieveObject: object, fromPeripheral: peripheral, fromCharachteristic: charachteristic)
                
            default:
                switch parseStatus {
                case .calm:
                    print("Recieving improperly cormatted data")
                    break
                case .recievingTag:
                    tag = ParsingTag(rawValue: char)
                    parseStatus = .recievingJSON
                
                case .recievingJSON:
                    jsonString.append(char)
                    
                }
            }
        }
    }
    
}
