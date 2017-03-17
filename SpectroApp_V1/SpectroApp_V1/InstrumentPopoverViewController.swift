//
//  InstrumentPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

protocol BluetoothResponder {
    func rescanForDevices()
}

class InstrumentPopoverViewController: UIViewController {

    @IBOutlet weak var scanButton: UIButton!
    var bleResponder: BluetoothResponder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        bleResponder.rescanForDevices()
    }

}
