//
//  DataMasterViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataMasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var sampleTableView: UITableView!
    
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
    
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sampleNames.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // FIXME: implement this to enable deleting a sample
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! DataTableViewCell
        
        cell.titleLabel!.text = sampleNames[indexPath.row]
        let measurementsText = sampleMeasurements[indexPath.row]
        cell.measurementsLabel!.text = measurementsText.joined(separator: "\t")
        cell.averageLabel!.text = sampleAverages[indexPath.row]
        cell.stdLabel!.text = sampleStds[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataHeader") as! DataHeaderTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    
    // MARK: segue functions
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if (segue.identifier == "showDetailView") {
     self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
     
     let detailView = segue.destination as! DetailViewController
     //let indexPath = sampleTableView.indexPath(for: sender as! UITableViewCell)
     
     // FIXME: implement this to accept data from the project view
     detailView.data = [["S1"], ["Unknown"], ["9:34AM", "12:00PM", "3:15PM"], ["This is just a test"]]
     
     }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     self.performSegue(withIdentifier: "showDetailView", sender: self)
     }
     */
    
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleTableView.delegate = self
        sampleTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
