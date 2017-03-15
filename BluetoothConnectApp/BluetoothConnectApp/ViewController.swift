//
//  ViewController.swift
//  BluetoothConnectApp
//
//  Created by Corban Swain on 2/22/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var labelCount: UILabel!
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    let BEAN_NAME = "BLESPIFRIEND"
    let BEAN_SCRATCH_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID = CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not avalible.")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
       
        if device?.contains(BEAN_NAME) == true {
            manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic.uuid == BEAN_SCRATCH_UUID {
            let count = characteristic.value!.withUnsafeBytes {
                Array(UnsafeBufferPointer<UInt32>(start: $0, count: characteristic.value!.count/MemoryLayout<UInt32>.size))
            }
            labelCount.text = NSString(format: "%llu", count) as String
        }
    }
    

}

