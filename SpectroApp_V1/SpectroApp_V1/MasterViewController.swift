//
//  ViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    /// Outlet to the container view in which the various view 
    /// controllers will be presented
    @IBOutlet weak var containerView: UIView!

    /// outlet to a toolbar button item serving as a label 
    /// to indicate the current experiment
    @IBOutlet weak var experimentName: UIBarButtonItem!
    
    /// instance of the project view controller; view controllers are
    /// implemented with lazy loading to prevent the costs of set up
    /// if a particular view controller is never used
    private lazy var projectViewController: ProjectViewController = {
        // force downcast new view controller instance to ```ProjectViewController```
        let viewController = self.instantiateViewController(withID: "ProjectViewController") as! ProjectViewController
        
        // add view controller as child view controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    /// instance of the data view controller; view controllers are
    /// implemented with lazy loading to prevent the costs of set up
    /// if a particular view controller is never used
    private lazy var dataViewController: DataViewController = {
        let viewController = self.instantiateViewController(withID: "DataViewController") as! DataViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    /// instance of the plot view controller; view controllers are
    /// implemented with lazy loading to prevent the costs of set up
    /// if a particular view controller is never used
    private lazy var plotViewController: PlotViewController = {
        let viewController = self.instantiateViewController(withID: "PlotViewController") as! PlotViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    /// an array of closures that each return the primary view controllers
    var viewControllers: [()->UIViewController] = []
    
    /// index of the current segmented control selection
    var segmentedControlIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the primary view controllers to the ```viewControllers``` array in the same order they appear in the segmented control; using closures here to preserve lazy loading
        viewControllers.append({ return self.projectViewController })
        viewControllers.append({ return self.dataViewController })
        viewControllers.append({ return self.plotViewController })
        
        // begin by loading the project view controller
        add(asChildViewController: projectViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Respond to change in the segmented controll selection;
    /// chnges the interface presented in the container view.
    ///
    /// - Parameter sender: ```UISegmentedControl``` object
    @IBAction func segmentedControllChanged(_ sender: UISegmentedControl) {
        let lastIndex = segmentedControlIndex
        segmentedControlIndex = sender.selectedSegmentIndex
        updateContainerView(from: lastIndex)
    }
    
    
    /// Adds a view controller to the master view's container view 
    /// and sets that view controller to be a child of the master 
    /// controller.
    ///
    /// - Parameter viewController: the new child view controller
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        
        // add child view as Subview within the containerView
        containerView.addSubview(viewController.view)
        
        // configure child view to fill within the containerView
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // notify child view controller
        viewController.didMove(toParentViewController: self)
    }
    
    
    /// Removes the current child view controller from its super view
    /// and clears it as the current child view controller.
    ///
    /// - Parameter viewController: the child view controller to be removed
    private func remove(asChildViewController viewController: UIViewController) {
        // notify child view controller
        viewController.willMove(toParentViewController: nil)
        
        // remove child view from superview
        viewController.view.removeFromSuperview()
        
        // notify child view controller
        viewController.removeFromParentViewController()
    }
    
    
    /// Transitions the container view from the old interface 
    /// to a new interface
    ///
    /// - Parameter index: the index of the old view controller in the 
    ///                    ```viewControllers``` array
    private func updateContainerView(from index: Int) {
        let newController = viewControllers[segmentedControlIndex]
        let oldController = viewControllers[index]
        remove(asChildViewController: oldController())
        add(asChildViewController: newController())
    }
    
    /// Creates a new view controller instance from a view controller
    /// on the main storyboard.
    ///
    /// - Parameter identifier: the StoryboardID of the view controller
    /// - Returns: the new view controller instance
    private func instantiateViewController(withID identifier: String) -> UIViewController {
        // load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // instantiate view controller
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
 }

