//
//  DataPointTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/25/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataPointTableViewCell: UITableViewCell {

    @IBOutlet weak var blankValueLabel: UILabel!
    @IBOutlet weak var rawValueLabel: UILabel!
    @IBOutlet weak var absValueLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var instrumentIDLabel: UILabel!
    @IBOutlet weak var connectionIDLabel: UILabel!
    @IBOutlet weak var repeatNumberLabel: UILabel!
    
    
    func setup(with dataPoint: DataPoint, index: Int? = nil) {
        blankValueLabel.text = Formatter.fourDigNum.string(fromOptional: dataPoint.baselineValue as NSNumber?)
        rawValueLabel.text = Formatter.fourDigNum.string(fromOptional: dataPoint.instrumentDataPoint?.measurementValue as NSNumber?)
        absValueLabel.text = "= " + (Formatter.numFmtr(numDecimals: 5).string(fromOptional: dataPoint.measurementValue as NSNumber?) ?? "unknown")
        timestampLabel.text = Formatter.hrMinSec.string(fromOptional: dataPoint.timestamp) ?? "undated"
        if let idp = dataPoint.instrumentDataPoint {
            tagLabel.textColor = .black
            tagLabel.text = "\(idp.tag.type.description) - \(idp.tag.index)"
            instrumentIDLabel.textColor = .black
            instrumentIDLabel.text = idp.instrumentID.uuidString
            connectionIDLabel.textColor = .black
            connectionIDLabel.text = idp.connectionSessionID.uuidString
        } else {
            tagLabel.textColor = .lightGray
            tagLabel.text = "no tag"
            instrumentIDLabel.textColor = .lightGray
            instrumentIDLabel.text = "no instrument"
            connectionIDLabel.textColor = .lightGray
            connectionIDLabel.text = "N/A"
        }
        repeatNumberLabel.text = "REPEAT " + (Formatter.intNum.string(fromOptional: index as NSNumber?) ?? "")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
