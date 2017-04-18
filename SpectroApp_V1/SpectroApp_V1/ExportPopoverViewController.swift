//
//  ExportPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExportPopoverViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var fileNameText: UITextField!
    
    var documentController : UIDocumentInteractionController!
    
    var project: Project!
    
    
    func writeDataToFile(file:String)-> Bool{
        // store the data to export
        
        let readings = project.readingArray
        var data = project.title + "\n"
        for (i,reading) in readings.enumerated() {
            if let value = reading.absorbanceValue {
                data.append(Formatter.threeDecNum.string(from: value as NSNumber)!)
                if i < readings.count - 1 {
                    data.append(",")
                }
            }
        }
        print(data)
        
        // get the file path for the file in the bundle
        // if it doesn't exist, make it in the bundle
        let fileName = file + ".txt"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            
            documentController = UIDocumentInteractionController(url: path)
            
            do {
                try data.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                return true
            }
            catch {
                print("could not write to file")
                return false
            }
            
        }
        return false
    }
    
    
    @IBAction func writeData(sender: UIButton) {
        if writeDataToFile(file: fileNameText.text!) {
            print("data written")
        } else {
            print("data not written")
        }
        documentController.presentOptionsMenu(from: sender.frame, in: self.view, animated:true)
    }

    
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
