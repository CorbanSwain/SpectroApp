//
//  ViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    /// Container View for specific interfaces
    @IBOutlet weak var containerView: UIView!
    
    /// Dictionary of primary view controllers
    var viewControllers: [()->UIViewController] = []
    
    /// Index of the current segmented control selection
    var segmentedControlIndex = 0
    
    private lazy var projectViewController: ProjectViewController = {
        // Force downcast new view controller instance to PlotViewController
        let viewController = MasterViewController.instantiateViewController("ProjectViewController") as! ProjectViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var dataViewController: DataViewController = {
        let viewController = MasterViewController.instantiateViewController("DataViewController") as! DataViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var plotViewController: PlotViewController = {
        let viewController = MasterViewController.instantiateViewController("PlotViewController") as! PlotViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add
        viewControllers.append({ return self.projectViewController })
        viewControllers.append({ return self.dataViewController })
        viewControllers.append({ return self.plotViewController })
        add(asChildViewController: projectViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /// Respond to change in segmented controll selection
    ///
    /// - Parameter sender: ```UISegmentedControl``` object
    @IBAction func segmentedControllChanged(_ sender: UISegmentedControl) {
        let lastIndex = segmentedControlIndex
        segmentedControlIndex = sender.selectedSegmentIndex
        updateContainerView(from: lastIndex)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        
        // add child view as Subview within the containerView
        containerView.addSubview(viewController.view)
        
        // Configure child view to fill within the containerView
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify child view controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // notify child view controller
        viewController.willMove(toParentViewController: nil)
        
        // remove child view from superview
        viewController.view.removeFromSuperview()
        
        // notify child view controller
        viewController.removeFromParentViewController()
    }
    
    private func updateContainerView(from index: Int) {
        let newController = viewControllers[segmentedControlIndex]
        let oldController = viewControllers[index]
        remove(asChildViewController: oldController())
        add(asChildViewController: newController())
    }
    
    private static func instantiateViewController(_ identifier: String) -> UIViewController {
        // load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // instantiate view controller
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
 }

