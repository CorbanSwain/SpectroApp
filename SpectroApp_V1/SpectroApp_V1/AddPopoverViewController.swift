//
//  AppPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class AddPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var newProjectTableView: UITableView!
    
    weak var delegate: ProjectChangerDelegate!
    
    let labels = ["Project Title", "Notes", "Notebook Reference", "Experiment Type"]
    
    // FIXME: don't us indices to get the experiment type
    var experimentType = 0
    
    
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem)  {
        let project = Project()
        
        // set the project properties based on the text field inputs
        var cell =  newProjectTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddProjectTableViewCell
        project.title = cell.textInput.text!
        
        cell =  newProjectTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! AddProjectTableViewCell
        project.notes = cell.textInput.text!
        
        cell =  newProjectTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! AddProjectTableViewCell
        project.notebookReference = cell.textInput.text!
        
        project.experimentType = ExperimentType(rawValue: Int16(experimentType))!
        
        project.editDate = Date()
        
        // save the project
        try? AppDelegate.viewContext.save()
        
        // set the new project as the active project
        delegate.prepareChange(to: project)
        delegate.commitChange()
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
            
            cell.experimentTypePicker.delegate = self
            cell.experimentTypePicker.dataSource = self
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 3 {
            return 50
        }
        else {
            return 100
        }

    }
    
    
    // MARK: picker view functions
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ExperimentType.allTypeStrings.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // FIXME: use the actual ExperimentTypes
        experimentType = row + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "SanFranciscoText-Light", size: 15)
        
        label.text = ExperimentType.allTypeStrings[row]
        
        return label
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newProjectTableView.delegate = self
        newProjectTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
