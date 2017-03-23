//
//  InstrumentPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

public let bleResponderKey = "BLE"

protocol InstrummentSettingsViewControllerDelegate: class {
    func rescanForDevices()
    func addReporter(_ newReporter: CBInstrumentCentralManagerReporter)
    func popReporter()
    func echoStatus()
}

class InstrumentPopoverViewController: UIViewController {
    
    weak var delegate: InstrummentSettingsViewControllerDelegate!
    @IBOutlet weak var instrumentAlertView: InstrumentAlertView!

    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentAlertView.setup(isFirstTime: false)
        delegate.addReporter(instrumentAlertView)
    }
    
    @IBAction func scanButtonPressed(_ sender: UIBarButtonItem) {
        delegate.rescanForDevices()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.popReporter()
    }
}
