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
    
    var delegates: [String:Any] = [:]
    var project: Project!
    
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
            
        case "popover.segue.add":
            let projectsVC = segue.destination as! AddPopoverViewController
            projectsVC.delegate = delegates[projectChangerDelegateKey]! as! ProjectChangerDelegate
            break
        case "popover.segue.export":
            let exportVC = segue.destination as! ExportPopoverViewController
            exportVC.project = project
            exportVC.documentControllerPresenter = delegates[docControllerPresenterKey] as! DocumentControllerPresenter
        case "popover.segue.info":
            print("Preparing for segue to project info popover\n\t↳ ProjectVC.prepare(for:sender:)")
            let projectVC = segue.destination as! ProjectViewController
            projectVC.project = project
        default:
            break
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let delegate = popoverPresentationController?.delegate, let popControl = popoverPresentationController else {
            super.dismiss(animated: flag, completion: nil)
            return
        }
        
        if delegate.popoverPresentationControllerShouldDismissPopover!(popControl) {
            super.dismiss(animated: flag, completion: nil)
        }
    }
    
}
