//
//  DataMasterViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataMasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dataTableView: UITableView!
    
    var dataViewController: DataViewController {
        return splitViewController as! DataViewController
    }
    
    var project: Project? {
        return dataViewController.project
    }
    
    var readingCache: [Reading]? {
        didSet {
            if let rs = readingCache, rs.count < 1 {
                readingCache = nil
            }
        }
    }
    
    func refreshReadingCache() {
        readingCache = nil
        guard let p = project else {
            return
        }
        readingCache = p.readingArray
    }
    
    lazy var numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 3
        nf.maximumFractionDigits = 3
        return nf
    }()
    
    // FIXME: use core data to access actual project info, pass project from ProjectVivarontroller
    //var sampleNames: [String]!
    //var sampleMeasurements: [[String]]!
    //var sampleAverages: [String]!
    //var sampleStds: [String]!
    
    //var header = "Sample Name\t\tMeasurements\t\tAverage\t\tStandard Deviation"
    var sampleNames = ["S1", "S2", "S3"]
    var sampleMeasurements = [["1","2","3"], ["5"], ["4","2"]]
    var sampleAverages = ["2", "5", "3"]
    var sampleStds = ["1", "0", "1.4142"]
    var sampleTypes = ["Unknown", "Known", "Blank"]
    var sampleTimes = [["9:34AM", "12:00PM", "3:15PM"],["10:00AM"],["4:30PM", "5:10PM"]]
    var sampleNotes = ["This is a sample of unknown concentration", "This is a sample of known concentration", "This is a blank sample"]
    
    
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rs = readingCache else {
            return 1
        }
        return rs.count
//        return self.sampleNames.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // FIXME: implement this to enable deleting a sample
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rs = readingCache else {
            // FIXME: return some "no data" table cell
            print("Attempting to load table when project has no data - DataMasterVC")
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Data in Project"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! DataTableViewCell
        let reading = rs[indexPath.row]
        
        cell.titleLabel.text = reading.label ?? "[untitled]"
        cell.measurementsLabel.text = reading.dataPointsStringArray.joined(separator: ", ")
        cell.averageLabel.text = numberFormatter.string(from: (reading.absorbanceValue ?? -1) as NSNumber)
        cell.stdLabel.text = numberFormatter.string(from: (reading.stdDev ?? -1) as NSNumber)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataHeader") as! DataHeaderTableViewCell
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetailView") {
            //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
     
            let dataDetailView = segue.destination as! DataDetailViewController
            let indexPath = dataTableView.indexPathForSelectedRow! as NSIndexPath
            dataDetailView.reading = readingCache?[indexPath.row]
     
            // FIXME: implement this to accept data from the project view
//            let sampleName = sampleNames[indexPath.row]
//            let sampleType = sampleTypes[indexPath.row]
//            let sampleTime = sampleTimes[indexPath.row]
//            let sampleNote = sampleNotes[indexPath.row]
            
     
        }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: self)
     }
    
    
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTableView.delegate = self
        dataTableView.dataSource = self
        refreshReadingCache()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
