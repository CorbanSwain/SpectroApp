//
//  DataViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataViewController: UISplitViewController {

    var project: Project! {
        didSet {
            guard let masterVC = childViewControllers[0] as? DataMasterViewController else {
                print("could not grab master VC")
                return
            }
            masterVC.project = project
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredPrimaryColumnWidthFraction = 0.7
        maximumPrimaryColumnWidth = 700
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
