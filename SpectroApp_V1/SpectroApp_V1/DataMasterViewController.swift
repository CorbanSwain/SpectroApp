//
//  DataMasterViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

class DataMasterViewController:  FetchedResultsTableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dataTableView: UITableView!
    
    var frc: NSFetchedResultsController<Reading>!
    
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
    
    
    
    // MARK: table view functions
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // FIXME: implement this to enable deleting a sample
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let rs = readingCache else {
//            // FIXME: return some "no data" table cell
//            print("Attempting to load table when project has no data - DataMasterVC")
//            let cell = UITableViewCell()
//            cell.textLabel?.text = "No Data in Project"
//            return cell
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! DataTableViewCell
        
        let reading = frc.object(at: indexPath)
        
        cell.titleLabel.text = reading.title ?? "[untitled]"
        cell.measurementsLabel.text = reading.dataPointsStringArray.joined(separator: ", ")
        cell.averageLabel.text = Formatter.threeDecNum.string(from: (reading.absorbanceValue ?? -1) as NSNumber)
        cell.stdLabel.text = Formatter.threeDecNum.string(from: (reading.stdDev ?? -1) as NSNumber)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "dataHeader") as! DataHeaderTableViewCell
//        return cell.contentView
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let typeInt = Formatter.intNum.number(from: (frc.sections?[section].name)!)! as! Int16
        return ReadingType(rawValue: typeInt)?.description ?? ReadingType.noType.description
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetailView") {
            //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
     
            let dataDetailView = segue.destination as! DataDetailViewController
            let indexPath = dataTableView.indexPathForSelectedRow! as NSIndexPath
            dataDetailView.reading = readingCache?[indexPath.row]            
     
        }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: self)
     }
    
    func setupFRC() {
        let request: NSFetchRequest<Reading> = Reading.fetchRequest()
        //let titleKey = "titleDB"
        //let titleSort = NSSortDescriptor(key: titleKey, ascending: false, selector: #selector(NSString.compare(_:)))
        let typeKey = "typeDB"
        let typeSort =  NSSortDescriptor(key: typeKey,  ascending: true, selector: #selector(NSNumber.compare(_:)))
        request.sortDescriptors = [typeSort]
        
        // FIXME: maybe `nil` project should be handled differently
        if let proj = project {
            request.predicate = NSPredicate(format: "project = %@", proj)
        }
        
        frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath: typeKey,
            cacheName: nil
        )
    }
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFRC()
        frc.delegate = self
        super.tableView = dataTableView
        dataTableView.delegate = self
        dataTableView.dataSource = self
        do {
            try frc.performFetch()
        } catch let error as NSError {
            print("Could not perform fetch! -- DataMasterVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
        // refreshReadingCache()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
