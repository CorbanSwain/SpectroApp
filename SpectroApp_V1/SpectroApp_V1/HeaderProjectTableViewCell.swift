//
//  HeaderProjectTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 4/24/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class HeaderProjectTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var textInput: UITextField!
    var editorRef: String?
    var project: Project!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if var t = textField.text as NSString?, let k = editorRef {
            t = t.replacingCharacters(in: range, with: string) as NSString
            project.setValue(t, forKey: k)
        }
        if AppDelegate.viewContext.hasChanges {
            try? AppDelegate.viewContext.save()
        }
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textInput.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
