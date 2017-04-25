//
//  DataMasterViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/11/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

enum SortSetting {
    case type
    case date
    case name
}

enum CellViewType {
    case generalView
    case nucleicAcidView
    case bradfordView
    case cellDensityView
    init(type:ExperimentType) {
        switch type {
        case .bradford:
            self = .bradfordView
        case .cellDensity:
            self = .cellDensityView
        case .nucleicAcid:
            self = .nucleicAcidView
        default:
            self = .generalView
        }
    }
}

class DataMasterViewController:  FetchedResultsTableViewController, UITableViewDataSource, UITableViewDelegate, DataCellDelegate {
    
    @IBOutlet weak var dataTableView: UITableView!
    
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!

    var selectionIndexPath: IndexPath? = nil
    
    @IBOutlet weak var headerView: UIView!
    
    var sortSetting = SortSetting.type {
        didSet {
            guard sortSetting != oldValue else {
                return
            }
            refrechFRCSort()
        }
    }
    
    var cellViewType = CellViewType.generalView {
        didSet {
            // TODO: refresh table header and the table data
            guard cellViewType != oldValue else {
                return
            }
            // or refrechFRCSort() ?
            dataTableView.reloadData()
        }
    }
    
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
        cell.indexPath = indexPath
        cell.delegate = self
        let reading = frc.object(at: indexPath)
        
        if let i = project?.readingArray.index(of: reading) {
            cell.setup(with: reading, index: (i + 1), viewType: cellViewType)
        } else {
            cell.setup(with: reading, viewType: cellViewType)
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "dataHeader") as! DataHeaderTableViewCell
//        return cell.contentView
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO: change this to update based on cell view type (i.e. experiment type)
        if sortSetting == .type {
            let typeInt = Formatter.intNum.number(from: (frc.sections?[section].name)!)! as! Int16
            return ReadingType(rawValue: typeInt)?.description ?? ReadingType.noType.description
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sortSetting == .type {
            if section == 0 {
                return 40
            } else {
                return 15
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == ((frc.sections?.count ?? 0) - 1) {
            print("Section \(section + 1) of \(frc.sections?.count ?? -1) --> returning 610 \n\t↳ DataMasterVC.tableView(_:heightForFooterInSection:")
            return 570
        } else {
            return 30
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 1
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
    
    func refrechFRCSort() {
        print("refresfing FRC\n\t↳ DataMasterVC")

        
        
        let request: NSFetchRequest<Reading> = Reading.fetchRequest()
        let keyPath: String?
        if let proj = project {
            request.predicate = NSPredicate(format: "project = %@", proj)
        } else {
            // FIXME: maybe `nil` project should be handled differently
        }
        
        switch sortSetting {
        case .type:
            request.sortDescriptors = [Reading.typeSort,Reading.dateSort]
            keyPath = Reading.typeKey
        case .name:
            request.sortDescriptors = [Reading.titleSort,Reading.dateSort]
            keyPath = nil
        case .date:
            request.sortDescriptors = [Reading.dateSort,Reading.titleSort]
            keyPath = nil
        }
        
        frc = NSFetchedResultsController(
            fetchRequest        : request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath  : keyPath,
            cacheName           : nil
        )
        frc.delegate = self
        
        do {
            print("Attempt at Fetching data!\n\t↳ DataMasterVC")
            try frc.performFetch()
            print("Completed Fetch!\n\t↳ DataMasterVC")
            dataTableView.reloadData()
        } catch let error as NSError {
            print("Could not perform fetch!\n\t↳ DataMasterVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
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
        do {
            try frc.performFetch()
            dataTableView.reloadData()
            detailViewController.reading = nil
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
    
    
    func dataCell(_ dataCell: DataTableViewCell, scrollUpTo indexPath: IndexPath) {
//        tableView.setContentOffset(CGPoint.zero, animated: true)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.layer.masksToBounds = false
//        headerView.layer.shadowColor = UIColor.darkGray.cgColor
        headerView.layer.shadowRadius = 3
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowOpacity = 0.5
        
        
        setupFRC()
        super.tableView = dataTableView
        do {
           print("fetching data -- DataMasterVC")
            try frc.performFetch()
            didSetupFRC = true
        } catch let error as NSError {
            print("Could not perform fetch! -- DataMasterVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
        dataTableView.delegate = self
        dataTableView.dataSource = self
        // refreshReadingCache()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
