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

    var tableInfo: [(header: String?, rows: [(String?, String)])] {
        if let cache = dataCache {
            return cache
        } else {
            guard let r = reading else {
                return []
            }
            let info = r.tableInfo
            dataCache = info
            return info
        }
            
    }
    var dataCache: [(header: String?, rows: [(String?, String)])]?
    
    // MARK: table view functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let r = reading else {
            return UITableViewCell()
        }
        
        if indexPath.section == tableInfo.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.detail.dataPoint", for: indexPath) as! DataPointTableViewCell
            cell.setup(with: r.dataPoints[indexPath.row], index: indexPath.row + 1)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell.detail.header", for: indexPath) as! HeaderDetailTableViewCell
            cell.mainLabel.text = tableInfo[indexPath.section].rows[indexPath.row].1
            if let headerText = tableInfo[indexPath.section].rows[indexPath.row].0 {
                cell.headerLabel.isHidden = false
                cell.headerLabel.text = headerText
            } else {
                cell.headerLabel.isHidden = true
            }
            return cell
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
            return "Repeated Values"
        } else {
            return tableInfo[section].header
        }
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

extension Reading {
    var tableInfo: [(header: String?, rows: [(String?, String)])] {
        let titleSec: [(String?, String)] = [
            (nil, title ?? "untitled"),
            ("Type:", type.description),
            ("Timestamp:", Formatter.monDayYr.string(fromOptional: timestamp) ?? "undated"),
        ]
        
        let absorbanceSec = [
            (nil, Formatter.numFmtr(numDecimals: 5).string(fromOptional: absorbanceValue as NSNumber?) ?? "no abs. value"),
            ("Std Dev:", "± " + (Formatter.numFmtr(numDecimals: 5).string(fromOptional: stdDev as NSNumber?) ?? "no abs. value")),
        ]
        // FIXME: also include calibration points
        
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
        
    }
}
