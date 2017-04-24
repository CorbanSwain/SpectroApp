//
//  HeaderProjectTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/24/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class HeaderProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var textInput: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
