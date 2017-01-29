//
//  ViewController.swift
//  AbsorbanceDataDisplay
//
//  Created by Corban Swain on 1/27/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bar1Height: NSLayoutConstraint!
    @IBOutlet weak var bar2Height: NSLayoutConstraint!
    @IBOutlet weak var bar3Height: NSLayoutConstraint!
    @IBOutlet weak var bar4Height: NSLayoutConstraint!
    @IBOutlet weak var bar5Height: NSLayoutConstraint!
    @IBOutlet weak var bar6Height: NSLayoutConstraint!
    @IBOutlet weak var bar7Height: NSLayoutConstraint!
    @IBOutlet weak var bar8Height: NSLayoutConstraint!
    @IBOutlet weak var bar9Height: NSLayoutConstraint!
    @IBOutlet weak var bar10Height: NSLayoutConstraint!
    
    @IBOutlet weak var barSection: UILabel!
    var barHeights: [NSLayoutConstraint?] = []
    var maxHeight: CGFloat = 728
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        barHeights = [bar1Height, bar2Height,
                      bar3Height, bar4Height,
                      bar5Height, bar6Height,
                      bar7Height, bar8Height,
                      bar9Height, bar10Height]
        maxHeight = barSection?.frame.size.height ?? maxHeight
        slopeBars()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slopeBars() {
        print("runngin slopeBars()")
        var i = 0
        for h in barHeights.enumerated() {
            i = h.offset
            h.element?.constant = CGFloat(i) * maxHeight / 10.0
            print("Bar \(i) h: \(h.element?.constant)")
        }
    }


    @IBAction func bar2Touched(_ sender: UIButton) {
        print("touched")
        bar2Height.constant = bar2Height.constant + CGFloat(5)
    }
    

}

