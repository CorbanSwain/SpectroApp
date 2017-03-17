//
//  ExportPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExportPopoverViewController: PopoverViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newVC = segue.destination as! MasterViewController
        newVC.instrumentAlertView.isGrayedOut = false
        
        guard let id = segue.identifier else {
            print("no segue ID")
            return
        }
        print("segueID: \(id)")
    }

}
