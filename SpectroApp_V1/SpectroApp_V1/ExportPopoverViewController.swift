//
//  ExportPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExportPopoverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
