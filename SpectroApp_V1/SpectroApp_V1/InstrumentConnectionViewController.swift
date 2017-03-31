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

    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentAlertView.setup(isFirstTime: false)
        delegate.addReporter(instrumentAlertView)
    }
    
    @IBAction func scanButtonPressed(_ sender: UIBarButtonItem) {
        delegate.rescanForDevices()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
//        guard let masterVC = self.parent?.parent as? MasterViewController else {
//            self.dismiss(animated: true, completion: nil)
//        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.popReporter()
    }
}
