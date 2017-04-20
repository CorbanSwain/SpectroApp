//
//  ExperimentHeaderView.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/20/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ExperimentHeaderView: UIView {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var backgroundAccent: UIView!
    @IBOutlet weak var titleField: UITextField!
    
    var mainText: String! {
        didSet {
            mainLabel.text = mainText ?? "Untitled"
        }
    }
    
    var subText: String! {
        didSet {
            subLabel.text = subText ?? ""
        }
    }

}
