//
//  AppPopoverViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func greyPlaceholderColor() -> UIColor {
        return UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
    }
    
}

class AddPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var newProjectTableView: UITableView!
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    weak var delegate: ProjectChangerDelegate!
    
    let labels = [["Project Title"], ["Experiment Type"], ["Notebook Reference", "Notes"]]
    var experimentType = ExperimentType.bradford
    
    
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem)  {
        let project = Project()
        
        // set the project properties based on the text field inputs
        var cell =  newProjectTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddProjectTableViewCell
        project.title = cell.textInput.text!
        
        cell =  newProjectTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! AddProjectTableViewCell
        project.notebookReference = cell.textInput.text!
        
        let cell2 =  newProjectTableView.cellForRow(at: IndexPath(row: 1, section: 2)) as! AddProjectNotesTableViewCell
        project.notes = cell2.textInput.text!
        
        project.experimentType = experimentType
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
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsAtSection: [Int] = [labels[0].count, labels[1].count, labels[2].count]
        var rows = 0
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }

        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectCell", for: indexPath) as! AddProjectTableViewCell
                cell.textInput.placeholder = labels[indexPath.section][indexPath.row]
                cell.separatorInset.left = 0
                return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectTypeCell", for: indexPath) as! AddProjectTypeTableViewCell
            cell.titleLabel.text = labels[indexPath.section][indexPath.row]
            cell.selectedLabel.text = experimentType.description
            cell.separatorInset.left = 0
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectCell", for: indexPath) as! AddProjectTableViewCell
                cell.textInput.placeholder = labels[indexPath.section][indexPath.row]
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectNotesCell", for: indexPath) as! AddProjectNotesTableViewCell
                cell.textInput.text = labels[indexPath.section][indexPath.row]
                cell.separatorInset.left = 0
                cell.textInput.textColor = UIColor.greyPlaceholderColor()
                cell.textInput.delegate = self
                cell.textInput.becomeFirstResponder()
                cell.textInput.selectedTextRange = cell.textInput.textRange(from: cell.textInput.beginningOfDocument, to: cell.textInput.beginningOfDocument)
                return cell
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText = textView.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if (updatedText?.isEmpty)! {
            
            textView.text = "Notes"
            textView.textColor = UIColor.greyPlaceholderColor()
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        else if textView.textColor == UIColor.greyPlaceholderColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.greyPlaceholderColor() {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 150
        }
        return 50
    }
    

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 35
        } else {
            return 35/3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 35
        } else {
            return 35/2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: "add.segue.type", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "add.segue.type":
            if let expTypeMenuVC = segue.destination as? ExperimentTypeViewController {
                expTypeMenuVC.type = experimentType
            }
        default:
            break
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        newProjectTableView.reloadData()
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
