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

    @IBOutlet weak var projectNotesLabel: UILabel!
    
    var project: Project! {
        didSet {
            guard let label = projectNotesLabel, let p = project else {
                return
            }
            label.text = p.notes
        }
    }
    
    func loadProject(_ project: Project) {
        print("loadingProject -- ProjectVC")
        self.project = project
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectNotesLabel.text = project.notes ?? "[no notes]"
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
