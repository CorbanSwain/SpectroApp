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
    
    var selectionIndexPath: IndexPath? = nil
    
    var frc: NSFetchedResultsController<Reading>!
    var didSetupFRC = false
    
    var detailViewController: DataDetailViewController {
        return dataViewController.viewControllers[1] as! DataDetailViewController
    }
    
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "showDetailView") {
//            //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
//     
//            let dataDetailView = segue.destination as! DataDetailViewController
//            let indexPath = dataTableView.indexPathForSelectedRow! as NSIndexPath
//            dataDetailView.reading = readingCache?[indexPath.row]            
//     
//        }
//     }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "showDetailView", sender: self)
//        print("indexPath: \(indexPath)  -- DataMasterVC.tableview")
//        print("reading: \(frc.object(at: indexPath))  -- DataMasterVC.tableview")
        selectionIndexPath = indexPath
        detailViewController.reading = frc.object(at: indexPath)
     }
    
    func refreshFRC() {
        
        guard didSetupFRC else {
            return
        }
        guard let proj = project else {
            // FIXME: need to do something is no project
            return
        }
        
        print("refreshing FRC -- DataMasterVC")
        frc.fetchRequest.predicate = NSPredicate(format: "project = %@", proj)
//        setupFRC()
        do {
            try frc.performFetch()
            dataTableView.reloadData()
            detailViewController.reading = nil
            if let indexPath = selectionIndexPath {
                if indexPath.section < (frc.sections?.count ?? 0) {
                    if indexPath.row < (frc.sections?[indexPath.section].numberOfObjects  ?? 0) {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                    }
                }
            }
            
        } catch let error as NSError {
            print("Could not perform fetch! -- DataMasterVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
//        masterVC?.refreshFRC()
    }
    
    func setupFRC() {
        print("settingup FRC -- DataMasterVC")
        let request: NSFetchRequest<Reading> = Reading.fetchRequest()
        let titleKey = "titleDB"
        let titleSort = NSSortDescriptor(key: titleKey, ascending: true, selector: #selector(NSString.compare(_:)))
        let typeKey = "typeDB"
        let typeSort =  NSSortDescriptor(key: typeKey,  ascending: true, selector: #selector(NSNumber.compare(_:)))
        request.sortDescriptors = [typeSort, titleSort]
        
        if let proj = project {
            request.predicate = NSPredicate(format: "project = %@", proj)
        } else {
            // FIXME: maybe `nil` project should be handled differently
        }
        frc = NSFetchedResultsController(
            fetchRequest        : request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath  : typeKey,
            cacheName           : nil
        )
        frc.delegate = self
        
    }
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFRC()
        super.tableView = dataTableView
        dataTableView.delegate = self
        dataTableView.dataSource = self
        do {
           print("fetching data -- DataMasterVC")
            try frc.performFetch()
            didSetupFRC = true
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
