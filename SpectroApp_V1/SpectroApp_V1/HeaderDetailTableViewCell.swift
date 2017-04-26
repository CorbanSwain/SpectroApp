//
//  HeaderDetailTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/25/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class HeaderDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
