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
    
    var observer: NSObjectProtocol?
    
    var reading: Reading? {
        didSet {
            tableInfoCache = nil
            print("reloading table! \n\t↳ DataDetailVC.reading[didSet]")
            detailTableView?.reloadData()
        }
    }

    var tableInfo: [(header: String?, rows: [(String?, String)])] {
        if let cache = tableInfoCache {
            return cache
        } else {
            guard let r = reading else {
                return []
            }
            let info = r.tableInfo
            tableInfoCache = info
            return info
        }
            
    }
    var tableInfoCache: [(header: String?, rows: [(String?, String)])]? = nil
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let r = reading else {
            return UITableViewCell()
        }
        
        if indexPath.section == tableInfo.count {
            let cell = detailTableView.dequeueReusableCell(withIdentifier: "cell.detail.dataPoint", for: indexPath) as! DataPointTableViewCell
            cell.setup(with: r.dataPoints[indexPath.row], index: indexPath.row + 1)
            return cell
        } else {
            if let headerText = tableInfo[indexPath.section].rows[indexPath.row].0 {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "cell.detail.header", for: indexPath) as! HeaderDetailTableViewCell
                cell.mainLabel.text = tableInfo[indexPath.section].rows[indexPath.row].1
                cell.headerLabel.text = headerText
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = tableInfo[indexPath.section].rows[indexPath.row].1
                cell.textLabel?.font = UIFont(name: "System", size: 19)
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == tableInfo.count {
            return 221
        } else {
            return 44
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard reading != nil else {
            return 0
        }
        return tableInfo.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let r = reading else {
            return 0
        }
        
        if section == tableInfo.count {
            return r.dataPoints.count
        } else {
            return tableInfo[section].rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard reading != nil else {
            return nil
        }
        
        if section == tableInfo.count {
            return "Repeated Measurements"
        } else {
            return tableInfo[section].header
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        if let o = observer {
            NotificationCenter.default.removeObserver(o)
        }
        
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: OperationQueue.main, using: { note in
            
            print("Notification sent...\n\t↳ DataDetailVC.viewDidLoad()")
            guard let cell = self.detailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HeaderDetailTableViewCell, let r = self.reading else {
                
                return
            }
            cell.mainLabel.text = r.title
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Reading {
    var tableInfo: [(header: String?, rows: [(String?, String)])] {
        let titleSec: [(String?, String)] = [
            ("Description:", title ?? "untitled"),
            ("Type:", type.description),
            ("Timestamp:", Formatter.monDayYr.string(fromOptional: timestamp) ?? "undated"),
        ]
        
        let absorbanceSec = [
            (nil, Formatter.numFmtr(numDecimals: 5).string(fromOptional: absorbanceValue as NSNumber?) ?? "no abs. value"),
            ("Std. Dev.:", "± " + (Formatter.numFmtr(numDecimals: 5).string(fromOptional: stdDev as NSNumber?) ?? "N/A")),
            ("# Repeats:", Formatter.intNum.string(from: dataPoints.count as NSNumber) ?? "0"),
        ]
        // FIXME: also include calibration points
        
        if hasConcentration {
            let concentrationSec: [(String?, String)] = [
                ("Has Conc?:", hasConcentration ? "Yes" : "No"),
                ("Concentation:", Formatter.numFmtr(numDecimals: 5).string(fromOptional: concentration as NSNumber?) ?? "no value"),
                ("Units:", "mM")
            ]
            return [
                ("Title", titleSec),
                ("Absorbance", absorbanceSec),
                ("Concentration", concentrationSec),
            ]
        } else {
            return [
                ("Reading Info", titleSec),
                ("Absorbance", absorbanceSec),
            ]
        }
    
        
    }
}
