//
//  InstrumentBluetoothManager.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol InstrumentBluetoothManagerReporter: class {
    func setStatusTo(_ status: InstrumentStatus)
}

class InstrumentBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, BluetoothResponder {
    var centralManager: CBCentralManager
    private let bleQueue = DispatchQueue.init(label: "bleQueue", qos: .utility)
    let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let uartTXCharID = CBUUID(string:    "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let uartRXCharID = CBUUID(string:    "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    

    let legoSpecID = UUID(uuidString: "EF520BC5-9EF2-4801-B395-DA0D146A4B65")
    var uartPeripherals: [UUID: CBPeripheral] = [:]
    var alertReporter: InstrumentBluetoothManagerReporter
    var connectedPeripheral: CBPeripheral? {
        willSet {
            guard let peripheral = connectedPeripheral else { return }
            if newValue == nil {
                uartPeripherals[peripheral.identifier] = nil
            }
        }
    }
    
    var uartService: CBService?
    var tryPeripheralID: UUID?
    
    init(withDelegate delegate: InstrumentBluetoothManagerReporter) {
        self.alertReporter = delegate
        centralManager = CBCentralManager(delegate: nil, queue: bleQueue)
        super.init()
        centralManager.delegate = self
    }
    
    func isOn() -> Bool {
        if centralManager.state == .poweredOn { return true }
        else { return false }
    }
    
    internal func rescanForDevices() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
        scanForPeripherals(withServices: [uartServiceUUID])
    }
    
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]) {
        alertReporter.setStatusTo(.busy)
        bleQueue.async {
            let startTime = Date()
            while !self.isOn() && startTime.timeIntervalSinceNow > -10 {
                print("timeinterval: \(startTime.timeIntervalSinceNow)")
            }
            guard self.isOn() else {
                print("time up!, BLE not powered on, scan again after turning bluetooth on")
                return
            }
            print("BLE On!, scanning for peripherals")
            DispatchQueue.main.async {
                self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
                Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.stopScanningForPeripherals), userInfo: nil, repeats: false)
            }
        }
    }
 
    
    func stopScanningForPeripherals() {
        guard centralManager.isScanning else {
            return
        }
        centralManager.stopScan()
        alertReporter.setStatusTo(.warning)
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Core Bluetooth Central Manager state changed!")
        if isOn() {
            scanForPeripherals(withServices: [uartServiceUUID])
        } else {
            uartPeripherals = [:]
            alertReporter.setStatusTo(.warning)
        }
        return
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let id = peripheral.identifier
        guard uartPeripherals[id] == nil && connectedPeripheral?.identifier != id else {
            print("peripherial already found")
            return
        }
        print("new perepherial -> \(peripheral)")
        uartPeripherals[id] = peripheral
        
        if id == legoSpecID {
            print("LEGO-spec found!")
            centralManager.stopScan()
            connectToPeripheral(withID: id)
        }
    }
    
    func connectToPeripheral(withID id: UUID) {
        guard let peripheral = uartPeripherals[id] else {
            print("Expected a peripheral, but it cannot be found")
            alertReporter.setStatusTo(.warning)
            return
        }
        tryPeripheralID = id
        centralManager.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to a peripheral")
        alertReporter.setStatusTo(.warning)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected!")
        connectedPeripheral = nil
        alertReporter.setStatusTo(.warning)
        scanForPeripherals(withServices: [uartServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let id = tryPeripheralID, peripheral.identifier == id else {
            print("Expected to connect to a different instrument!")
            alertReporter.setStatusTo(.warning)
            central.cancelPeripheralConnection(peripheral)
            return
        }
        print("Connected to a peripheral!")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        tryPeripheralID = nil
        peripheral.discoverServices([uartServiceUUID])
        print("searcing for services....")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Error no services found")
            alertReporter.setStatusTo(.warning)
            return
        }
        print("Found a Service!")
        alertReporter.setStatusTo(.busy)
        for service in services {
            if service.uuid == uartServiceUUID {
                print("sucessfully connected to UART service")
                uartService = service
                peripheral.discoverCharacteristics([uartRXCharID], for: service)
                print("attemting to discover charachteristics...")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let charachteristics = service.characteristics,
            charachteristics.count > 0 else {
                
            print("Error no charachteristics found")
            alertReporter.setStatusTo(.warning)
            return
        }
        
        print("\(charachteristics.count) charachteristic(s) found!")
        alertReporter.setStatusTo(.busy)
        
        for c in charachteristics {
            if c.uuid == uartRXCharID {
                print("Sucessfully found UART RX charachteristics")
                subscribe(toCharachteristic: c, onPeripheral: peripheral)
                alertReporter.setStatusTo(.good)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("service.includedServices: \(service.includedServices)")
    }
    
    func subscribe(toCharachteristic charachteristic: CBCharacteristic, onPeripheral peripheral: CBPeripheral) {
        print("Subscribing to a charachteristic...")
        peripheral.setNotifyValue(true, for: charachteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("no data found for \(characteristic.uuid)")
            return
        }
        let string = String(data: data, encoding: String.Encoding.utf8)
        print((string ?? "[nil]"), terminator: "")
        
    }
    
}
