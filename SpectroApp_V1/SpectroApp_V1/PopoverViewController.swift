//
//  PopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/17/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

// Clicking Project populates
// --> 
// Hook up to core data



import UIKit

class PopoverNavigationController: UINavigationController {

    var passThroughViews: [UIView]? {
        didSet {
            guard let views = passThroughViews else {
                return
            }
            popoverPresentationController?.passthroughViews = views
        }
    }
    
    var delegates: [String:Any] = [:]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("In segue: \(segue.identifier ?? "[no segue ID]")")
        
        guard let id = segue.identifier else {
            print("No segue ID; cannot prepare for segue.")
            return
        }
        
        switch id {
        case "popover.segue.instrument":
            let instrumentVC = segue.destination as! InstrumentConnectionViewController
            instrumentVC.delegate = delegates[instrumentConnectionVCDelegateKey]! as! InstrummentConnectionViewControllerDelegate
            
        case "popover.segue.projects":
            let projectsVC = segue.destination as! ProjectsPopoverViewController
            projectsVC.delegate = delegates[projectChangerDelegateKey]! as! ProjectChangerDelegate
            break
            
        default:
            break
        }
    }
    
}
