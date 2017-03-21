//
//  InstrumentPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

public let bleResponderKey = "BLE"

protocol BluetoothResponder {
    func rescanForDevices()
    func addReporter(_ newReporter: InstrumentBluetoothManagerReporter)
    func popReporter()
    func echoStatus()
}

class InstrumentPopoverViewController: UIViewController {
    
    var bleResponder: BluetoothResponder!
    @IBOutlet weak var instrumentAlertView: InstrumentAlertView!

    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentAlertView.setup(isFirstTime: false)
        bleResponder.addReporter(instrumentAlertView)
        bleResponder.echoStatus()
    }
    
    @IBAction func scanButtonPressed(_ sender: UIBarButtonItem) {
        bleResponder.rescanForDevices()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bleResponder.popReporter()
    }
    

}
