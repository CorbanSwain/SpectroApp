//
//  AddProjectNotesTableViewCell.swift
//  SpectroApp_V1
//
//  Created by Mary Richardson on 4/19/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class AddProjectNotesTableViewCell: UITableViewCell,  UITextViewDelegate {
    
    @IBOutlet weak var textInput: UITextView!
    var editorRef = "notesDB"
    var project: Project!
    
    func textViewDidChange(_ textView: UITextView) {
        if let t = textView.text as NSString? {
            project.setValue(t, forKey: editorRef)
        }
        if AppDelegate.viewContext.hasChanges {
            try? AppDelegate.viewContext.save()
        }
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
