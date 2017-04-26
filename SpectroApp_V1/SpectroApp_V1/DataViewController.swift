//
//  DataViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataViewController: UISplitViewController, ProjectPresenter {

    var masterVC: DataMasterViewController? {
        guard let masterVC = viewControllers.first as? DataMasterViewController else {
            print("could not load master VC -- Data VC")
            return nil
        }
        return masterVC
    }
    
    var project: Project! {
        didSet {
            masterVC?.refreshFRC()
            masterVC?.setTableViewCellType()
            masterVC?.setHeaderView()
        }
    }

    func loadProject(_ project: Project) {
        print("loadingProject -- DataVC")
        self.project = project
    }
    
//        {
//        didSet {
//            print("did set project in DataVC")
//            guard let masterVC = splitViewController?.viewControllers.first as? DataMasterViewController else {
//                print("could not grab master VC")
//                return
//            }
//            // masterVC.project = project
//        }
//    }

    
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
