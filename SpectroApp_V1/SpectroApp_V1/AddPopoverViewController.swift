//
//  AppPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class AddPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newProjectTableView: UITableView!
    
    let labels = ["Project Title", "Notes", "Notebook Reference", "Experiment Type"]
    let experimentTypes = ["Bradford Assay", "Cell Density", "Nuecleic Acid Concentration", "Unknown Exp."]
    
    
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem)  {
        let project = Project()
        // FIXME: set the project properties based on the text field inputs
        var cell =  newProjectTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddProjectTableViewCell
        project.title = cell.textInput.text!
        
        cell =  newProjectTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! AddProjectTableViewCell
        project.notes = cell.textInput.text!
        
        cell =  newProjectTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! AddProjectTableViewCell
        project.notebookReference = cell.textInput.text!
        
        //cell = newProjectTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! AddProjectTypeTableViewCell
        //project.experimentType = ExperimentType(rawValue: Int16(rand(1,3))) //FIXME make this a dropdown and use the index selected
        
        // try? AppDelegate.viewContext.save()
        // FIXME: set the new project as the active project
        dismiss()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        // FIXME: clear all text fields if necesary
        dismiss()
    }
    
    func dismiss() {
        (navigationController as! PopoverNavigationController).dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectCell", for: indexPath) as! AddProjectTableViewCell
            cell.titleLabel.text = labels[indexPath.row]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectTypeCell", for: indexPath) as! AddProjectTypeTableViewCell
            cell.titleLabel.text = labels[indexPath.row]
            return cell
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newProjectTableView.delegate = self
        newProjectTableView.dataSource = self
        
        //myPicker.dataSource = self
        //myPicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
