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

class ProjectsPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var projectTableView: UITableView!

    
    weak var delegate: ProjectChangerDelegate!
    
    var fetchedResultController: NSFetchedResultsController<Project>!
   
    var projects: [Project]!

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // MARK: table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(fetchedResultController ?? "no controller")
        print("num sections: \(fetchedResultController.sections?.count ?? -9999)")
        return fetchedResultController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.projects.count
        if let sections =  fetchedResultController.sections, sections.count > 0 {
            print("Some number of rows: \(sections[section].numberOfObjects)")
            return sections[section].numberOfObjects
        } else {
            print("no rows!")
            return 0
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
        let obj = fetchedResultController.object(at: indexPath)
        cell.titleLabel?.text = obj.title
        cell.typeLabel?.text = obj.experimentType.description
        //print(formatter.string(for: formatter.date(from: projectDates[indexPath.row])))
        cell.dateLabel?.text = Formatter.monDayYr.string(fromOptional: obj.editDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.prepareChange(to: fetchedResultController.object(at: indexPath))
        // FIXME: could add animations here
        cancelButton.isEnabled = true
        doneButton.title = "Open"
        doneButton.tintColor = .green
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let a = Int16(Formatter.intNum.number(from: (fetchedResultController.sections?[section].name)!)!)
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
        (navigationController as! PopoverNavigationController).dismiss(animated: true, completion: nil)
    }
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.isEnabled = false
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let sortDescr1 = NSSortDescriptor(key: "dateSectionDB", ascending: true, selector: #selector(NSNumber.compare(_:)))
        let sortDescr2 = NSSortDescriptor(key: "editDateDB", ascending: false, selector: #selector(NSDate.compare(_:)))
        request.sortDescriptors = [sortDescr1, sortDescr2]
        fetchedResultController = NSFetchedResultsController<Project>(
            fetchRequest        : request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath  : "dateSectionDB",
            cacheName           : nil)
        
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        projectTableView.delegate = self
        projectTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
