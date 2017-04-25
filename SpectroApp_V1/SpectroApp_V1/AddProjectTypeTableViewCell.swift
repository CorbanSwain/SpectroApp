//
//  AddProjectTypeTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/15/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class AddProjectTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
