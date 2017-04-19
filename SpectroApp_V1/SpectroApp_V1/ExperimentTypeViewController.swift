//
//  ExperimentTypeViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/18/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExperimentTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var experimentTypeTableView: UITableView!
    
    let labels = ExperimentType.allTypeStrings
    var type = ExperimentType.bradford
    
    
    // MARK: table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "experimentTypeCell", for: indexPath) as! ExperimentTypeTableViewCell
        cell.titleLabel.text = labels[indexPath.row]
        
        // FIXME: this should add a checkmark to the selected type!
        if (labels[indexPath.row] == type.description) {
            print(labels[indexPath.row])
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            cell.accessoryType = .checkmark
        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            cell.accessoryType = .none
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        type = ExperimentType.allTypes[indexPath.row]
        tableView.reloadData()
        performSegue(withIdentifier: "unwind.segue.add", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwind.segue.add" {
            let addVC = segue.destination as! AddPopoverViewController
            addVC.experimentType = type
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        experimentTypeTableView.delegate = self
        experimentTypeTableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
