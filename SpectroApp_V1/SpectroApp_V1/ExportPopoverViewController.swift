//
//  ExportPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

protocol DocumentControllerPresenter {
    func prepareDocController(withURL url: URL)
    func presentDocController()
}

class ExportPopoverViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var fileNameText: UITextField!
    
    var documentControllerPresenter: DocumentControllerPresenter!
    
    var documentController : UIDocumentInteractionController!
    
    var project: Project!
    
    var url: URL!
    
    func formatString(strings: [String], delim: String) -> String {
        var csv = ""
        for (i,s) in strings.enumerated() {
            csv.append(s)
            if i < strings.count - 1 {
                csv.append(delim)
            }
        }
        return csv
    }
    
    func formatData(readings: [Reading]) -> String {
        let labels = ["Reading Time", "Reading Title", "Reading Type", "Average Value", "Std Dev", "Number of Repeats", "Calibration Value", "Calibration Std Dev", "Number of Calibration Repeats"]
        var data = formatString(strings: labels, delim: ",") + "\n"
        
        for reading in readings {
            let readingTime = Formatter.monDayYrHrMinExcel.string(fromOptional: reading.timestamp)
            let readingTitle = reading.title!
            let readingType = reading.type.description
            let averageValue = Formatter.tenDecNum.string(fromOptional: reading.absorbanceValue as NSNumber?) ?? ""
            let stdDev = Formatter.tenDecNum.string(fromOptional: reading.stdDev as NSNumber?) ?? ""
            let numRepeats = String(reading.dataPoints.count)
            let calibrationValue = Formatter.tenDecNum.string(fromOptional: reading.absorbanceValueCalibration as NSNumber?) ?? ""
            let calibrationStdDev = Formatter.tenDecNum.string(fromOptional: reading.stdDevCalibration as NSNumber?) ?? ""
            let calibrationNumRepeats = String(reading.calibrationPoints.count)
    
            let values: [String] = [readingTime, readingTitle, readingType, averageValue, stdDev, numRepeats, calibrationValue, calibrationStdDev, calibrationNumRepeats]
        
            data.append(formatString(strings: values, delim: ",") + "\n")
        }
        return data
    }
    
    func formatHeader(project: Project, fileName: String) -> String {
        let info = "Info," + "Autogenerated from SpectroApp V0.1 - " + fileName + " - on " + Formatter.monDayYrExcel.string(from: Date())
        let title = "Title," + project.title
        let notebookRef = "Notebook Reference," + project.notebookReference
        let creationDate = "Creation Date," + Formatter.monDayYrExcel.string(fromOptional: project.creationDate)
        let editDate = "Edit Date," + Formatter.monDayYrExcel.string(fromOptional: project.editDate)
        let experimentType = "Experiment Type," + project.experimentType.description
        let notes = "Notes," + project.notes
        let creator = "Creator Name," + (project.creator?.firstNameDB ?? "") + " " + (project.creator?.lastNameDB ?? "")
        let username = "Creator Username," + (project.creator?.username ?? "")
        
        let values: [String] = [info, title, notebookRef, creationDate, editDate, experimentType, notes, creator, username]
        
        let data = formatString(strings: values, delim: "\n")
        return data
    }
    
    
    func writeDataToFile(file: String) -> Bool {
        
        let fileName = file + ".csv"
        
        // format the header info
        var data = formatHeader(project: project, fileName: fileName) + "\n\n"
        
        // format the data
        let readings = project.readingArray
        data.append(formatData(readings: readings))
        
        
        // get the file path
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            
            documentController = UIDocumentInteractionController(url: path)
            documentControllerPresenter.prepareDocController(withURL: path)
            do {
                print(data)
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
        // FIXME: - decide which is better...
        // A.
//        documentController.presentOpenInMenu(from: view.frame, in: view, animated: true)
        // or B.
        dismiss(animated: true, completion: documentControllerPresenter.presentDocController)
        
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
