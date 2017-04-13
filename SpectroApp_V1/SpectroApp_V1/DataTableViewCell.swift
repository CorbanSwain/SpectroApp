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
    
    var numberLabels: Set<UILabel> {
        return [measurementsLabel, averageLabel, stdLabel]
    }
    
    func tabularizeLabel(_ label: UILabel) {
        let originalDescriptor = label.font.fontDescriptor
        let figureCaseDict = [
            UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
            UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector,
        ]
        let attributes = [
            UIFontDescriptorFeatureSettingsAttribute: [ figureCaseDict ],
        ]
        let descriptor = originalDescriptor.addingAttributes(attributes)
        let tabularizedFont = UIFont(descriptor: descriptor, size: 0)
        label.font = tabularizedFont
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for l in numberLabels {
            tabularizeLabel(l)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
