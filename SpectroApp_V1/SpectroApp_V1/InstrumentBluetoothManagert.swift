//
//  BluetoothKit.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

class InstrumentBluetoothManager {
    var manager: CBCentralManager
    
    init() {
        manager = CBCentralManager()
    }
    
    func checkIfOn() -> Bool {
        if manager.state == .poweredOn { return true }
        else { return false }
    }
}
