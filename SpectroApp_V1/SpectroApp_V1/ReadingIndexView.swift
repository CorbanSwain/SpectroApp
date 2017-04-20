//
//  ReadingIndexView.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/19/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ReadingIndexView: UIView {

    @IBOutlet weak var indexLabel: UILabel!
    var didSetup = false
    
    func setup() {
        guard !didSetup else {
            return
        }
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        indexLabel.text = "!"
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

