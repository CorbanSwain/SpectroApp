//
//  ProjectViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController, ProjectPresenter, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var project: Project? {
        didSet {
            print("Did set project: \(project?.title ?? "[ERROR: nil project]")\n\t↳ ProjectVC.project[didSet]")
            refreshProject()
        }
    }
    
    var tableInfoCache: Array<[(String, ProjectInfoCellType)]>?
    var tableSectionTitlesCache: [String?]?
    
    var tableInfo: Array<[(String, ProjectInfoCellType)]> {
        if let info = tableInfoCache {
            return info
        } else {
            if let info = project?.tableInfo {
                tableInfoCache = info
                return info
            } else {
             return []
            }
            
        }
    }
    
    var tableSectionTitles: [String?] {
        if let titles = tableSectionTitlesCache {
            return titles
        } else {
            if let titles = project?.tableInfoSectionTitles {
                tableSectionTitlesCache = titles
                return titles
            } else {
                return []
            }
        }
    }
    
    func refreshProject() {
        print("refreshing project! \n\t↳ ProjectVC.refreshProject()")
        print("Project: \(project?.title ?? "[ERROR: nil project]")\n\t↳ ProjectVC.refreshProject()")
        tableView?.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableInfo[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableInfo.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let project = project else {
            return UITableViewCell()
        }
        let str = tableInfo[indexPath.section][indexPath.row].0
        let cellType = tableInfo[indexPath.section][indexPath.row].1
        return cellType.dequeCell(from: tableView, with: str, project: project, delegate: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableInfo[indexPath.section][indexPath.row].1 {
        case ProjectInfoCellType.notes:
            return 150
        default:
            return 50
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if project == nil {
            return "No project open, no info to display."
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch tableInfo[indexPath.section][indexPath.row].1 {
        case .menu:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableInfo[indexPath.section][indexPath.row].1 {
        case .menu:
            performSegue(withIdentifier: "info.segue.type", sender: self)
        default:
            return
        }
    }
    
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        tableView.scrollToRow(at:  IndexPath(row: 0, section: 0), at: .top, animated: true)
        let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddProjectTableViewCell
        titleCell?.textInput.becomeFirstResponder()
    }
    
    @IBAction func doneButtomPressed(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    func dismiss() {
        resignFirstResponder()
        (navigationController as! PopoverNavigationController).dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let id = segue.identifier else {
            print("no segue ID, cannot prepare. \n\t↳ ProjectVC.prepare(for:sender:)")
            return
        }
        
        switch id {
        case "info.segue.type":
            let experimentTypeVC = segue.destination as! ExperimentTypeViewController
            experimentTypeVC.type = project?.experimentType ?? .noType
            break
        default:
            break
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        super.unwind(for: unwindSegue, towardsViewController: subsequentVC)
        print("here! \n\t↳ ProjectVC.unwind")
    }
    
    func loadProject(_ project: Project) {
        print("loadingProject -- ProjectVC")
        self.project = project
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refreshProject()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

enum ProjectInfoCellType {
    
    case notes
    case uneditable(String?)
    case menu(String?, String)
    case simple(String?, String)
    
    func dequeCell(from tableView: UITableView, with string: String, project: Project, delegate: ProjectViewController) -> UITableViewCell {
        switch self {
        case .menu(let tags):
            let headerStr = tags.0
//            let editorRef = tags.1
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.select") as! AddProjectTypeTableViewCell
            cell.titleLabel?.text = string
            if let h = headerStr {
                switch h {
                case "Exp. Type:":
                    cell.selectedLabel.text = h
                default:
                    break
                }
                
            } else {
                cell.stackView.removeArrangedSubview(cell.selectedLabel)
                cell.selectedLabel.isHidden = true
            }
            return cell
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.notes") as! AddProjectNotesTableViewCell
            cell.textInput.text = string
            cell.project = project
            return cell
        case .simple(let tags):
            let headerStr = tags.0
            let editorRef = tags.1
            if let h = headerStr {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.header") as! HeaderProjectTableViewCell
                cell.header.text = h
                cell.textInput.text = string
                cell.textInput.textColor = UIColor.black
                cell.contentView.backgroundColor = UIColor.clear
                cell.textInput.isEnabled = true
                cell.project = project
                cell.editorRef = editorRef
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.general") as! AddProjectTableViewCell
                cell.textInput.text = string
                cell.textInput.textColor = UIColor.black
                cell.contentView.backgroundColor = UIColor.clear
                cell.textInput.isEnabled = true
                cell.project = project
                cell.editorRef = editorRef
                return cell
            }
        case .uneditable(let headerStr):
            if let h = headerStr {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.header") as! HeaderProjectTableViewCell
                cell.header.text = h
                cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.09)
                cell.textInput.text = string
                cell.textInput.textColor = UIColor.darkGray
                cell.textInput.isEnabled = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.general") as! AddProjectTableViewCell
                cell.textInput.text = string
                cell.textInput.textColor = UIColor.darkGray
                cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.09)
                cell.textInput.isEnabled = false
                return cell
            }
            
        }
    }
}

extension Project {
    var tableInfo: Array<[(String, ProjectInfoCellType)]> {
        
        let titleSec = [
            (title, ProjectInfoCellType.simple(nil, "titleDB"))
        ]
        
        let readingSec = [
            ((Formatter.intNum.string(from: readings.count as NSNumber) ?? "0"), ProjectInfoCellType.uneditable(nil))
        ]
        
        let refSec = [
            (notebookReference ?? "", ProjectInfoCellType.simple(nil, "notebookReferenceDB"))
        ]
        
        let notesSec = [
            (notes, ProjectInfoCellType.notes)
        ]
        
        let dateSec = [
            (Formatter.fullLongDate.string(fromOptional: creationDate) ?? "", ProjectInfoCellType.uneditable("Created on:")),
            (Formatter.fullLongDate.string(fromOptional: editDate) ?? "", ProjectInfoCellType.uneditable("Last Edited:"))
        ]
        
        let creatorSec = [
            ((creator?.firstName ?? "") + " " + (creator?.lastName ?? ""), ProjectInfoCellType.uneditable("Full Name:")),
            (creator?.username ?? "", ProjectInfoCellType.uneditable("Username:"))
        ]
        
        let typeSec = [
            (experimentType.description, ProjectInfoCellType.menu(nil, "experimentTypeDB"))
        ]
        
        return [
            titleSec,
            dateSec,
            typeSec,
            readingSec,
            creatorSec,
            refSec,
            notesSec
        ]
    }
    
    var tableInfoSectionTitles: [String?] {
        return [
            "Title",
            "Timestamps",
            "Experiment Type",
            "# of Readings",
            "Creator",
            "Notebook Reference",
            "Notes"
        ]
    }
}
