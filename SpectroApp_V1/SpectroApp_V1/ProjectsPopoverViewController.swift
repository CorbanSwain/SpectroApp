//
//  ProjectsPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreData

public var projectChangerDelegateKey = "projChange"
protocol ProjectChangerDelegate: class {
    func prepareChange(to project: Project)
    func commitChange()
    func cancelChange()
}

class ProjectsPopoverViewController: FetchedResultsTableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var projectTableView: UITableView!

    
    weak var delegate: ProjectChangerDelegate!
    
    var frc: NSFetchedResultsController<Project>!
    var didSetupFRC = false
    
    var projects: [Project]!

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        print(fetchedResultController ?? "no controller")
//        print("num sections: \(fetchedResultController.sections?.count ?? -9999)")
        return frc.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.projects.count
        if let sections =  frc.sections, sections.count > 0 {
//            print("Some number of rows: \(sections[section].numberOfObjects)")
            return sections[section].numberOfObjects
        } else {
//            print("no rows!")
            return 0
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchStr = searchText
        if searchStr == "" {
            print("Search String is empty!\n\t↳ ProjectPopoverVC.searchBar")
            if frc.fetchRequest.predicate != nil {
                frc.fetchRequest.predicate = nil
            }
        } else {
            print("New search string: \(searchStr)\n\t↳ ProjectsPopoverVC.searchBarDidBeginEditing(_:)")
            let predicate = NSPredicate(format: "( titleDB CONTAINS [c] %@ )|| ( experimentTypeStringDB CONTAINS [c] %@ ) || ( notebookReferenceDB CONTAINS [c] %@ )", searchStr, searchStr, searchStr)
            frc.fetchRequest.predicate = predicate
        }
        
        do {
            print("fetching data!\n\t↳ ProjectPopoverVC")
            try frc.performFetch()
            projectTableView.reloadData()
        } catch let error as NSError {
            print("Could not perform fetch!\n\t↳ ProjectPopoverVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // FIXME: implement this to enable deleting a project
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell
        let obj = frc.object(at: indexPath)
        cell.titleLabel?.text = obj.title
        cell.typeLabel?.text = obj.experimentType.description
        cell.dateLabel?.text = Formatter.monDayYr.string(fromOptional: obj.editDate)
        cell.numReadsLabel?.text = (Formatter.intNum.string(from: obj.readings.count as NSNumber) ?? "no") + " readings"
        cell.referenceLabel?.text = obj.notebookReference ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.prepareChange(to: frc.object(at: indexPath))
        // FIXME: could add animations here
        doneButton.isEnabled = true
//        doneButton.tintColor = .green
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let a = Int16(Formatter.intNum.number(from: (frc.sections?[section].name)!)!)
        return DateSection(rawValue: a)!.header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    // MARK: Navigation Button Functions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        delegate.commitChange()
        dismiss()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate.cancelChange()
        dismiss()
    }
    
    func dismiss() {
        resignFirstResponder()
        (navigationController as! PopoverNavigationController).dismiss(animated: true, completion: nil)
    }
    
    // MARK: Feteched Result Controller Functions
    
    func setupFRC() {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        // FIXME: add keys and sort descriptors to each class
        let dateSectionKey = "dateSectionDB"
        let dateSectionSort = NSSortDescriptor(key: dateSectionKey, ascending: true, selector: #selector(NSNumber.compare(_:)))
        let editDateKey = "editDateDB"
        let editDateSort = NSSortDescriptor(key: editDateKey, ascending: false, selector: #selector(NSDate.compare(_:)))
        request.sortDescriptors = [dateSectionSort, editDateSort]
        frc = NSFetchedResultsController<Project>(
            fetchRequest        : request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath  : dateSectionKey,
            cacheName           : nil
        )
        frc.delegate = self
    }

    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: only refresh so often not upon every loading
        searchBar.delegate = self
        if Project.refreshAllDateSections() {
            do {
                try AppDelegate.viewContext.save()
                print("saved \n\t↳ ProjectsPopoverVC.viewDidLoad()")
            } catch let error as NSError {
                print("ERROP: Could not save.\nSAVING ERROR: \(error.debugDescription)\n\t↳ ProjectsPopoverVC.viewDidLoad()")
            }
        }
        
        tableView = projectTableView
        doneButton.title = "Open"
        doneButton.isEnabled = false
        setupFRC()
        // FIXME: maybe add perroemfetch to its own function...implement in super class?
        do {
            print("fetching data!\n\t↳ ProjectPopoverVC")
            try frc.performFetch()
            didSetupFRC = true
        } catch let error as NSError {
            print("Could not perform fetch!\n\t↳ ProjectPopoverVC\nFETCHING ERROR: \(error), \(error.userInfo)")
        }
        
        projectTableView.delegate = self
        projectTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
