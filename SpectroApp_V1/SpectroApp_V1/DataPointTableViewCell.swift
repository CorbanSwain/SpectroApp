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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
