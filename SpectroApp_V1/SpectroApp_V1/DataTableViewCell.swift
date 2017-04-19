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
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var stdLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    var numberLabels: Set<UILabel> {
        return [averageLabel, stdLabel]
    }
    
    func tabularizeLabels(_ labels: Set<UILabel>) {
        for label in labels {
        let originalDescriptor = label.font.fontDescriptor
                let descriptor = originalDescriptor.addingAttributes(Formatter.tabularFiguresAttributes)
        let tabularizedFont = UIFont(descriptor: descriptor, size: 0)
        label.font = tabularizedFont
        }
    }
    
    func setup(with reading: Reading, index: Int? = nil) {
//        indexLabel.text = Formatter.intNum.string(fromOptional: index as NSNumber?) ?? "?"
        titleLabel.text = reading.title ?? "[untitled]"
        averageLabel.text = Formatter.threeDecNum.string(fromOptional: reading.absorbanceValue as NSNumber?) ?? "???"
        stdLabel.text = Formatter.threeDecNum.string(fromOptional: reading.stdDev as NSNumber?) ?? "???"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tabularizeLabels(numberLabels)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
