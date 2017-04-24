//
//  DataTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

protocol DataCellDelegate {
    func dataCell(_ dataCell: DataTableViewCell, scrollUpTo indexPath: IndexPath)
}

class DataTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var typeView: ReadingTypeView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var stdLabel: UILabel!
    @IBOutlet weak var indexView: ReadingIndexView!
    @IBOutlet weak var repeatImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var indexPath: IndexPath!
    var delegate: DataCellDelegate!
    
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
    
    var reading: Reading!
    
    func setup(with reading: Reading, index: Int? = nil) {
        indexView.setup()
        typeView.setup()
        self.reading = reading
        
        typeView.setType(reading.type)
        if let i = index {
            indexView.indexLabel.text = Formatter.intNum.string(from: i as NSNumber)
        } else {
            indexView.indexLabel.text = "?"
        }
        
        if let title = reading.title {
            titleField.textColor = .black
            titleField.text = title
        } else {
            titleField.textColor = .gray
            titleField.text = "Unnamed"
        }
        
        if let average = Formatter.threeDecNum.string(fromOptional: reading.absorbanceValue as NSNumber?) {
            averageLabel.textColor = .black
            averageLabel.text =  average
        } else {
            averageLabel.textColor = .gray
            averageLabel.text = "???"
        }
        
        if let stdDev = Formatter.threeDecNum.string(fromOptional: reading.stdDev as NSNumber?)  {
            stdLabel.textColor = .black
            stdLabel.text =  stdDev
        } else {
            stdLabel.textColor = .gray
            stdLabel.text = "???"
        }
        
        let numRepeats = reading.dataPoints.count
        repeatImageView.image = DataTableViewCell.getRepeatImage(from: numRepeats)
        
        timeLabel.text = ""
        if numRepeats > 0 {
            let date = reading.dataPoints[0].timestamp
            timeLabel.text = Formatter.monDayYrRetHrMin.string(fromOptional: date) ?? "undated"
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate.dataCell(self, scrollUpTo: indexPath)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        reading.title = textField.text
        // FIXME: - not handling a thrown error
        try? AppDelegate.viewContext.save()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleField.delegate = self
        tabularizeLabels(numberLabels)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    static func getRepeatImage(from numRepeats: Int) -> UIImage {
        guard numRepeats > 0 else {
            return #imageLiteral(resourceName: "zero")
        }
        
        switch numRepeats {
        case 1: return #imageLiteral(resourceName: "one")
        case 2: return #imageLiteral(resourceName: "two")
        case 3: return #imageLiteral(resourceName: "three")
        case 4: return #imageLiteral(resourceName: "four")
        case 5: return #imageLiteral(resourceName: "five")
        case 6: return #imageLiteral(resourceName: "six")
        default: return #imageLiteral(resourceName: "six")
        }
    }

}
