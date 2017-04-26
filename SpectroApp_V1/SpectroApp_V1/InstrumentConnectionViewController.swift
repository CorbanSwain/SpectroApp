//
//  InstrumentPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

public let instrumentConnectionVCDelegateKey = "BLE"

protocol InstrummentConnectionViewControllerDelegate: class {
    func rescanForDevices()
    func addReporter(_ newReporter: CBInstrumentCentralManagerReporter)
    func popReporter()
    func echoStatus()
}

class InstrumentConnectionViewController: UIViewController {
    
    weak var delegate: InstrummentConnectionViewControllerDelegate!
    @IBOutlet weak var instrumentAlertView: InstrumentStatusView!
    @IBOutlet weak var simulateSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        simulateSwitch.setOn(InstrumentConnectionViewController.beganSimulating, animated: false)
        instrumentAlertView.setup(isFirstTime: false)
        delegate.addReporter(instrumentAlertView)
    }
    
    @IBAction func scanButtonPressed(_ sender: UIBarButtonItem) {
        delegate.rescanForDevices()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        (navigationController as! PopoverNavigationController).dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.popReporter()
    }
    
    static var beganSimulating = false
    static var timers: [Timer] = []
    
    @IBAction func simulateSwitched(_ sender: UISwitch) {
        guard sender.isOn != InstrumentConnectionViewController.beganSimulating else {
            return
        }
        
        if InstrumentConnectionViewController.beganSimulating {
            for timer in InstrumentConnectionViewController.timers {
                timer.invalidate()
            }
            InstrumentConnectionViewController.timers = []
            InstrumentConnectionViewController.beganSimulating = false
        } else {
            InstrumentConnectionViewController.timers.append(TestDataGenerator.scheduleBlankTimer())
            InstrumentConnectionViewController.timers.append(TestDataGenerator.scheduleReadingTimer())
            InstrumentConnectionViewController.beganSimulating = true
        }
    }
}
