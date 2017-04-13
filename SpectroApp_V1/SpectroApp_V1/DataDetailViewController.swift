//
//  DataDetailViewController.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/10/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var detailTableView: UITableView!
    
    // FIXME: use real data
    let sections = ["Sample Name", "Sample Type", "Times", "Notes"]
    var data = [["S1"], ["Unknown"], ["9:34AM", "12:00PM", "3:15PM"], ["This is just a test"]]
    
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailViewCell", for: indexPath) as! DataDetailTableViewCell
        
        cell.titleLabel?.text = data[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
