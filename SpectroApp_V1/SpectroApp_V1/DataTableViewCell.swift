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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var typeView: ReadingTypeView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var stdLabel: UILabel!
    @IBOutlet weak var indexView: ReadingIndexView!
    @IBOutlet weak var repeatImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var valueView: UIStackView!
    
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
    
    func setup(with reading: Reading, index: Int? = nil, viewType: CellViewType) {
        // every view has num repeats, type, title
        self.reading = reading
        
        setTitle()
        
        typeView.setup()
        typeView.setType(reading.type)
        
        let numRepeats = reading.dataPoints.count
        repeatImageView.image = DataTableViewCell.getRepeatImage(from: numRepeats)
        
        switch viewType {
        case .bradfordView:
            // index, concentration
            setIndex(index: index)
            setConcentration()
            
            timeLabel.isHidden = true
            averageLabel.isHidden = true
            stdLabel.isHidden = true
            
            // hide +/- and std dev
            valueView.arrangedSubviews[1].isHidden = true
            valueView.arrangedSubviews[2].isHidden = true
        case .cellDensityView:
            // avg, std dev, time stamp
            setAverage()
            setStandardDeviation()
            setTimestamp(numRepeats: numRepeats)
            
            indexView.isHidden = true
        case .nucleicAcidView:
            // index, calibration ratio
            // don't set avg and std dev because we have a calibration ratio
            setIndex(index: index)
            setCalibrationRatio()

            timeLabel.isHidden = true
            
            // hide +/- and std dev
            valueView.arrangedSubviews[1].isHidden = true
            valueView.arrangedSubviews[2].isHidden = true
        default:
            // avg, std dev, index, timestamp
            setAverage()
            setStandardDeviation()
            setIndex(index: index)
            setTimestamp(numRepeats: numRepeats)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate.dataCell(self, scrollUpTo: indexPath)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.yellow.withAlphaComponent(0.18)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newStr = NSString(string: text).replacingCharacters(in: range, with: string)
            reading.title = newStr
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        reading.title = textField.text
        textField.backgroundColor = UIColor.clear
        do {
            try AppDelegate.viewContext.save()
            print("Saved context! \n\t↳ DataTableViewCell.textFieldDidEndEditing(_:)")
        } catch let error as NSError {
            print("Could not save.\nSAVING ERROR: \(error.debugDescription) \n\t↳ DataTableViewCell.textFieldDidEndEditing(_:)")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleField.delegate = self
        tabularizeLabels(numberLabels)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
       
        var actions: () -> Void
        if selected {
            actions = {
                self.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                self.titleField.font = UIFont.boldSystemFont(ofSize: self.titleField.font?.pointSize ?? 17)
                self.contentView.layer.borderWidth = 1
                self.contentView.layer.borderColor = UIColor.black.cgColor
                self.indexView.backgroundColor = .black
                self.indexView.indexLabel.textColor = .white
            }
        } else {
            actions = {
                self.contentView.backgroundColor = .clear
                self.titleField.font = UIFont.systemFont(ofSize: self.titleField.font?.pointSize ?? 17)
                self.contentView.layer.borderWidth = 0
                self.contentView.layer.borderColor = UIColor.clear.cgColor
                self.indexView.backgroundColor = .white
                self.indexView.indexLabel.textColor = .black
            }
        }
        
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: actions, completion: nil)
//            UIView.animate(withDuration: 0.1, animations: actions)
        } else {
            actions()
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        var actions: () -> Void
        
        if highlighted {
            actions = {
                self.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }
        } else {
            actions = {
                self.contentView.backgroundColor = UIColor.white
            }
        }
        
        if animated {
            UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: actions, completion: nil)
//            UIView.animate(withDuration: 0.1, animations: actions)
        } else {
            actions()
        }
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
    
    // helper methods
    func setIndex(index: Int? = nil) {
        indexView.setup()
        indexView.isHidden = false
        if let i = index {
            indexView.indexLabel.text = Formatter.intNum.string(from: i as NSNumber)
        } else {
            indexView.indexLabel.text = "?"
        }
    }
    
    func setTitle() {
        titleField.isHidden = false
        if let title = reading.title {
            titleField.textColor = .black
            titleField.text = title
        } else {
            titleField.textColor = .gray
            titleField.text = "Unnamed"
        }
    }
    
    func setAverage() {
        averageLabel.isHidden = false
        if let average = Formatter.threeDecNum.string(fromOptional: reading.absorbanceValue as NSNumber?) {
            averageLabel.textColor = .black
            averageLabel.text =  average
        } else {
            averageLabel.textColor = .gray
            averageLabel.text = "???"
        }
    }
    
    func setStandardDeviation() {
        stdLabel.isHidden = false
        if let stdDev = Formatter.threeDecNum.string(fromOptional: reading.stdDev as NSNumber?)  {
            stdLabel.textColor = .black
            stdLabel.text =  stdDev
        } else {
            stdLabel.textColor = .gray
            stdLabel.text = "???"
        }
    }
    
    func setTimestamp(numRepeats: Int) {
        timeLabel.isHidden = false
        timeLabel.text = ""
        if numRepeats > 0 {
            let date = reading.dataPoints[0].timestamp
            timeLabel.text = Formatter.monDayYrRetHrMin.string(fromOptional: date) ?? "undated"
        }
    }
    
    func setConcentration() {
        averageLabel.isHidden = false
        // TODO: set concentration label
        if let concentration = Formatter.threeDecNum.string(fromOptional: reading.concentration as NSNumber?) {
            // concentrationLabel.textColor = .black
            // concentrationLabel.text = concentration
             averageLabel.textColor = .black
             averageLabel.text = concentration
        } else {
            // concentrationLabel.textColor = .gray
            // concentrationLabel.text = "???"
             averageLabel.textColor = .gray
             averageLabel.text = "???"
        }
    }
    
    func setCalibrationRatio() {
        averageLabel.isHidden = false
        // TODO: set calibration ratio
        if let calibrationRatio = Formatter.threeDecNum.string(fromOptional: reading.calibrationRatio as NSNumber?) {
            // calibrationRatioLabel.textColor = .black
            // calibrationRatioLabel.text = calibrationRatio
             averageLabel.textColor = .black
             averageLabel.text = calibrationRatio
            
        } else {
            // calibrationRatioLabel.textColor = .gray
            // calibrationRatioLabel.text = "???"
             averageLabel.textColor = .gray
             averageLabel.text = "???"
        }
    }

}
