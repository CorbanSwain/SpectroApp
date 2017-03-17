//
//  BluetoothKit.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

class InstrumentBluetoothManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager
    private var BLEQueue = { return DispatchQueue.init(label: "BLEQueue", qos: .utility) }()
    let UART_UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    
    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: BLEQueue)
        super.init()
        centralManager.delegate = self
    }
    
    func checkIfOn() -> Bool {
        if centralManager.state == .poweredOn { return true }
        else { return false }
    }
    
    func scanForUARTPeripherals() {
        BLEQueue.async {
            let startTime = Date()
            while !self.checkIfOn() && startTime.timeIntervalSinceNow > -10 { }
            guard self.checkIfOn() else {
                print("time up!, BLE not powered on, scan again after turning bluetooth on")
                return
            }
            print("BLE On!, scanning for peripherals")
            DispatchQueue.main.async {
                self.centralManager.scanForPeripherals(withServices: [self.UART_UUID], options: nil)
            }
        }
        
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Core Bluetooth Central Manager state changed!")
        if checkIfOn() {
            scanForUARTPeripherals()
        }
        return
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("new perepherial -> \(peripheral)")
    }
    
}
