//
//  DataTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var measurementsLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var stdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
