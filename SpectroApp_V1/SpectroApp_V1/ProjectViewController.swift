//
//  ProjectViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

/// Does something
class ProjectViewController: UIViewController, ProjectPresenter {

    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var editedDate: UILabel!
    @IBOutlet weak var experimentType: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var numberOfSamples: UILabel!
    @IBOutlet weak var notebookReference: UILabel!
    @IBOutlet weak var notes: UILabel!
    
    let noDateStr = "[no date]"
    
    func refreshProject() {
        guard let createdDateLabel = createdDate, let editedDateLabel = editedDate,
            let experimentTypeLabel = experimentType, let creatorLabel = creator,
            let numberOfSamplesLabel = numberOfSamples, let notebookReferenceLabel = notebookReference,
            let notesLabel = notes, let p = project else {
            return
        }
        
        createdDateLabel.text = Formatter.monDayYr.string(fromOptional: p.creationDate)
        editedDateLabel.text = Formatter.monDayYr.string(fromOptional: p.editDate)
        experimentTypeLabel.text = p.experimentType.description
        creatorLabel.text = p.creator?.username
        numberOfSamplesLabel.text = String(p.readings.count)
        notebookReferenceLabel.text = p.notebookReference ?? "[none]"
        notesLabel.text = p.notes
        
    }
    

    var project: Project! {
        didSet {
            refreshProject()
        }
    }
    
    func loadProject(_ project: Project) {
        print("loadingProject -- ProjectVC")
        self.project = project
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshProject()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
