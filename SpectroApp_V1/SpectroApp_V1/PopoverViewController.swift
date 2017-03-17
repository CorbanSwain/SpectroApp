//
//  PopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/17/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    var passThroughViews: [UIView]?
    
    override func viewWillAppear(_ animated: Bool) {
        guard let passThroughViews = passThroughViews else {
            print("self.passThroughViews is nil")
            return
        }
        popoverPresentationController?.passthroughViews = passThroughViews
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
