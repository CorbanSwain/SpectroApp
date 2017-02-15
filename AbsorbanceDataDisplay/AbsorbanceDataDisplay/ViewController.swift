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
        print("runnging slopeBars()...")
        var i = 0
        for h in barHeights.enumerated() {
            i = h.offset
            h.element?.constant = ( CGFloat(i) * (maxHeight - 50) / 10.0 ) + 50
            print("Bar \(i) height: \(h.element?.constant)")
        }
    }

    
    @IBAction func bar1Touched(_ sender: UIButton) {
        changeBarHeight(ofBar: 1, by: 10)
    }
    
    @IBAction func bar2Touched(_ sender: UIButton) {
        changeBarHeight(ofBar: 2, by: 10)
    }
    
    @IBAction func bar3Touched(_ sender: UIButton) {
        changeBarHeight(ofBar: 3, by: 10)
    }
    
    @IBAction func bar4Touched(_ sender: UIButton) {
        changeBarHeight(ofBar: 4, by: 10)
    }
    
    @IBAction func bar5Touched(_ sender: UIButton) {
        changeBarHeight(ofBar: 5, by: 10)
    }

    func changeBarHeight(ofBar barNum: Int, by delta: CGFloat) {
        print("running changeBarHeight(barNum:delta:)...")
        if barNum <= 0 {
            print("barNum too small")
            return
        } else if barNum > barHeights.count {
            print("barNum too large")
            return
        }
        var newHeight = (barHeights[barNum - 1]?.constant ?? 0.0) + delta
        if newHeight < 0 {
            print("delta too small")
            newHeight = 0
        }
        else if newHeight > maxHeight {
            print("delta too large")
            newHeight = 0
        }
        barHeights[barNum - 1]?.constant = newHeight
    }
    
    func setBarHeight(ofBar barNum: Int, toPercent percent: CGFloat) {
        print("running changeBarHeight(barNum:percent:)...")
        if barNum <= 0 {
            print("barNum too small")
            return
        } else if barNum > barHeights.count {
            print("barNum too large")
            return
        }
        var newHeight = percent * maxHeight
        if newHeight < 0 {
            print("percent too small")
            newHeight = 0
        }
        else if newHeight > maxHeight {
            print("delta too large")
            newHeight = maxHeight
        }
        barHeights[barNum - 1]?.constant = newHeight
    }
}

