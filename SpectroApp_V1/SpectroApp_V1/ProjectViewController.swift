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
    
    func refreshProject() {
        print("refreshing project! \n\t↳ ProjectVC.refreshProject()")
        print("Project: \(project?.title ?? "[ERROR: nil project]")\n\t↳ ProjectVC.refreshProject()")
        tableView?.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project?.tableInfo[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return project?.tableInfo.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return project?.tableInfoSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str = project?.tableInfo[indexPath.section][indexPath.row].0 ?? "????"
        let cellType = project?.tableInfo[indexPath.section][indexPath.row].1
        return cellType!.dequeCell(from: tableView, with: str)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let x = project?.tableInfo[indexPath.section][indexPath.row].1 {
            switch x {
            case ProjectInfoCellType.notes:
                return 150
            default:
                return 50
            }
        } else {
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
    case menu
    case notes
    case simple(String?)
    case uneditable(String?)
    
    func dequeCell(from tableView: UITableView, with string: String) -> UITableViewCell {
        switch self {
        case .menu:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.select") as! AddProjectTypeTableViewCell
            cell.textLabel?.text = string
            return cell
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.notes") as! AddProjectNotesTableViewCell
            cell.textInput.text = string
            return cell
        case .simple(let headerStr):
            if let h = headerStr {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.header") as! HeaderProjectTableViewCell
                cell.header.text = h
                cell.textInput.text = string
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.general") as! AddProjectTableViewCell
                cell.textInput.text = string
                return cell
            }
        case .uneditable(let headerStr):
            if let h = headerStr {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.header") as! HeaderProjectTableViewCell
                cell.header.text = h
                cell.textInput.text = string
                cell.textInput.isEnabled = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell.project.general") as! AddProjectTableViewCell
                cell.textInput.text = string
                cell.textInput.isEnabled = false
                return cell
            }
            
        }
    }
}

extension Project {
    var tableInfo: Array<[(String, ProjectInfoCellType)]> {
        let descriptor = readings.count == 1 ? "reading" : "readings"
        let readingSec = [
            ((Formatter.intNum.string(from: readings.count as NSNumber) ?? "0") + " " + descriptor, ProjectInfoCellType.uneditable(nil))
        ]
        
        let noteSec = [
            (notebookReference ?? "", ProjectInfoCellType.simple(nil)),
            (notes, ProjectInfoCellType.notes)
        ]
        
        let dateSec = [
            (Formatter.fullLongDate.string(fromOptional: creationDate) ?? "", ProjectInfoCellType.uneditable("Created:")),
            (Formatter.fullLongDate.string(fromOptional: editDate) ?? "", ProjectInfoCellType.uneditable("Last Edited:"))
        ]
        
        let creatorSec = [
            ((creator?.firstName ?? "") + " " + (creator?.lastName ?? ""), ProjectInfoCellType.uneditable(nil)),
            (creator?.username ?? "", ProjectInfoCellType.uneditable("Username:"))
        ]
        return [
            dateSec,
            readingSec,
            creatorSec,
            noteSec
        ]
    }
    
    var tableInfoSectionTitles: [String?] {
        return [
            "Date",
            "Number of Readings",
            "Creator",
            "Reference and Notes"
        ]
    }
}
