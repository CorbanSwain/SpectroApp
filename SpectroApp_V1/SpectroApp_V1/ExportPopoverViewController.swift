//
//  ExportPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExportPopoverViewController: UIViewController {
    
    
    
    
    
    func writeDataToFile(file:String)-> Bool{
        // store the data to export
        let data = "Testing"
        
        // get the file path for the file in the bundle
        // if it doesn't exist, make it in the bundle
        let fileName = file + ".txt"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            
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
    
        /*
        if let filePath = Bundle.main.path(forResource: file, ofType: "txt"){
            fileName = filePath
        } else {
            fileName = Bundle.main.bundlePath + fileName
        }
        // write the file, return true if it works, false otherwise
        do {
            try data.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch{
            return false
        }
        */
    
    
    @IBAction func writeData(sender: UIButton) {
        if writeDataToFile(file: "data") {
            print("data written")
        } else {
            print("data not written")
        }
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
