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
    func changeProject(to project: Project)
}

class ProjectsPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var projectTableView: UITableView!

    // FIXME: use core data to access actual project info
    // RESOLVED
    
    var delegate: ProjectChangerDelegate!
    
    var projects: [Project] {
        let request: NSFetchRequest<Project> = NSFetchRequest(entityName: "Project")
        let sortDescr = NSSortDescriptor(key: "timestamp", ascending: false, selector: #selector(NSDate.compare(_:)))
        request.sortDescriptors = [sortDescr]
        do {
            let result = try AppDelegate.viewContext.fetch(request)
            return result
        } catch {
            print("could not fetch projects")
            return []
        }
    }
    
    var projectNames: [String] = ["First Experiment", "Second Experiment", "Third Experiment"]
    var projectTypes: [String] = ["Protein", "Nucleic Acid", "Cell Density"]
    var projectDates: [String] = ["2017-03-25", "2017-03-20", "2017-01-1"]
    
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // FIXME: implement this to enable deleting a project
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell
        
        cell.titleLabel!.text = projects[indexPath.row].title
        cell.typeLabel!.text = projects[indexPath.row].experimentType.description
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d H:mm a"
        //print(formatter.string(for: formatter.date(from: projectDates[indexPath.row])))
        cell.dateLabel!.text = formatter.string(for: projects[indexPath.row].timestamp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.changeProject(to: projects[indexPath.row])
    }
    
    //when you click a project
    //overview: show the project title at the top
    //show experiment type, date, notes
    
    
    // MARK: segue functions
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if (segue.identifier == "showDataView") {
     self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
     
     let dataView = segue.destination as! DataViewController
     //let indexPath = sampleTableView.indexPath(for: sender as! UITableViewCell)
     
     // FIXME: implement this to accept data from the project view
     dataView.sampleNames = ["S1", "S2", "S3"]
     dataView.sampleMeasurements = [["1","2","3"], ["5"], ["4","2"]]
     dataView.sampleAverages = ["2", "5", "3"]
     dataView.sampleStds = ["1", "0", "1.4142"]
     
     }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     self.performSegue(withIdentifier: "showDataView", sender: self)
     self.dismiss(animated: true, completion: nil)
     }
     */
    
    
    // MARK: default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectTableView.delegate = self
        projectTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
