//
//  InstrumentBluetoothManager.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth


/// An example JSON string to show the format for measuments sent by a connected instrument
public let instrumentDPStringExample = "{\"Index\":\"4\", \"Value\":\"2776\", \"Tag\":\"control\", \"TagNumber\":\"2\", \"Identifier\":\"24566781\"}"


/// A 128-bit universially unnique identifier (UUID) for the UART service, for more information about the UART service see [adafruit.learn.com](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
fileprivate let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

/// The UUID for the transmission charachteristic of the [UART service](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service)
fileprivate let uartTXCharID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")


/// The UUID for the recieving charachteristic of the [UART service](https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service), data from the instrment is sent through this charachteristic
fileprivate let uartRXCharID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")


/// The UUID for the LEGO Spectrophotometer peripheral: the device used for app testing, Spring 2017. The arduino in this device is an [Adafruit Feather M0 Bluefruit LE](https://learn.adafruit.com/adafruit-feather-m0-bluefruit-le/overview).
fileprivate let legoSpecID = UUID(uuidString: "EF520BC5-9EF2-4801-B395-DA0D146A4B65")


/// The ```CBInstrumentCentralManagerReporter``` protocol defines the methods that a reporter delegate of a CBInstrumentCentralManager object must adopt.

/// The CBCentralManagerDelegate protocol defines the methods that a delegate of a CBCentralManager object must adopt. The optional methods of the protocol allow the delegate to monitor the discovery, connectivity, and retrieval of peripheral devices. The only required method of the protocol indicates the availability of the central manager, and is called when the central manager’s state is updated.
protocol CBInstrumentCentralManagerReporter: class {
    func display(_ status: InstrumentStatus, message: String?)
}

class CBInstrumentCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBDataParserDelegate, InstrummentConnectionViewControllerDelegate {
    
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
    
    var status: (status: InstrumentStatus, message: String?) = (.busy, "Initializing …") {
        didSet {
            if tempStatus != nil { tempStatus = nil }
            echoStatus()
        }
    }
    var tempStatus: (status: InstrumentStatus, message: String?)?
    
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
        scanForPeripherals()
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
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.rescanForDevices), userInfo: nil, repeats: false)
        }
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
                status = (.good, "Connected to instrument. Waiting for incoming data …")
                
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
    
    func dataParser(_ dataParser: CBDataParser, didBeginParsingObjectWithTag tag: CBDataParser.ParsingTag, FromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        status = (.busy,"Recieving \(tag) …")
    }
    
    internal func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, withTag tag: CBDataParser.ParsingTag, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic) {
        switch parsedObject {
        case let instrumentDP as InstrumentDataPoint:
            print("Just got a data point!\n    --> \(instrumentDP)")
        default:
            print("Recieved an object, but it was of an unknown type.")
            break
        }
        tempStatus = (.good, "Recieved \(tag). Waiting for more incoming data …")
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.loadTempStatus), userInfo: nil, repeats: false)
        }
    }

    func loadTempStatus() {
        guard let s = tempStatus else { return }
        status = s
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
    func dataParser(_ dataParser: CBDataParser, didRecieveObject parsedObject: Any, withTag tag: CBDataParser.ParsingTag, fromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic)
    func dataParser(_ dataParser: CBDataParser, didBeginParsingObjectWithTag tag: CBDataParser.ParsingTag, FromPeripheral peripheral: CBPeripheral, fromCharachteristic charachteristic: CBCharacteristic)
}

