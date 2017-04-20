//
//  ReadingTypeView.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/19/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ReadingTypeView: UIView {

    @IBOutlet weak var typeLetterLabel: UILabel!
    var didSetup = false
    
    func setup() {
        guard !didSetup else {
            return
        }
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 1
        backgroundColor = .clear
        typeLetterLabel.text = "!"
    }
    
    func setType(_ type: ReadingType) {
       let color = type.color
        backgroundColor = color.withAlphaComponent(0.2)
        layer.borderColor = color.withAlphaComponent(0.7).cgColor
        typeLetterLabel.text = String(type.letter)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ReadingType {
    var color: UIColor {
        let c: UIColor
        switch self {
        case .blank:
            c = .lightGray
        case .control:
            c = .black
        case .custom:
            c = .green
        case .known:
            c = .cyan
        case .wildType:
            c = .brown
        case .mutant:
            c = .orange
        case .unknown:
            c = .blue
        case .standard:
            c = .yellow
        case .noType:
            c = .red
        }
        return c
    }
    
    var letter: Character {
        let c: Character
        switch self {
        case .blank:
            c = "B"
        case .control:
            c = "C"
        case .custom:
            c = "A"
        case .known:
            c = "K"
        case .wildType:
            c = "W"
        case .mutant:
            c = "M"
        case .unknown:
            c = "U"
        case .standard:
            c = "S"
        case .noType:
            c = "?"
        }
        return c
    }
}
