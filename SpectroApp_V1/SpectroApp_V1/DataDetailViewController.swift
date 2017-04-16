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
    
    var reading: Reading? {
        didSet {
            dataCache = nil
            print("reloading table! -- DataDetailVC")
            detailTableView?.reloadData()
        }
    }

    let sections = ["NAME", "TYPE", "POINTS", "BASELINES", "TIMES"]
    var data: Array<[String]> {
        if dataCache == nil {
            guard let r = reading else {
                return []
            }
            let name = r.title ?? "[untitled]"
            let type = r.type.description
            var points: [String] = []
            var baselines: [String] = []
            var times: [String] = []
            for (i,point) in r.dataPointArray.enumerated() {
                if let val = point.measurementValue {
                    points.append("\(i): " + (Formatter.threeDecNum.string(from: val as NSNumber) ?? "???"))
                } else {
                    points.append("\(i): " + "???")
                }
                baselines.append("\(i): " + (Formatter.fourDigNum.string(from: point.baselineValue as NSNumber) ?? "???"))
                if let ts = point.timestamp {
                    times.append("\(i): " + (Formatter.hrMin.string(from: ts as Date)))
                } else {
                    times.append("\(i): " + "[no date]")
                }
                
            }
            dataCache = [[name],[type],points,baselines,times]
        }
        guard let cache = dataCache else {
            print("dataCache somehow still nil after loading in a reading. --DataDetailVC")
            return []
        }
        return cache
    }
    var dataCache: Array<[String]>?
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailViewCell", for: indexPath) as! DataDetailTableViewCell
        
        cell.titleLabel?.text = data[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
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
