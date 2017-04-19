//
//  ViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ProjectPresenter {
    func loadProject(_ project: Project)
}

class MasterViewController: UIViewController, UIPopoverPresentationControllerDelegate, ProjectChangerDelegate, DatabaseDelegate, DocumentControllerPresenter {
    
    var lastActiveProject: Project? = nil
    var activeProject: Project! {
        didSet {
            guard oldValue != activeProject else {
                // same project
                return
            }
//            print("didSet active project -- MasterVC")
            guard let activeProj = activeProject else {
                print("WARNING: just set the active project to nil. --MasterVC")
                return
            }
            print("Set `activeProject` to: \(activeProj.title)\n\t↳ MasterVC.activeProject-didSet")
            headerView.mainText = activeProj.title
            headerView.subText = Formatter.monDayYr.string(from: activeProj.creationDate! as Date)
            guard let projectPresenter = childViewControllers.first as? ProjectPresenter else {
                print("could not load project presenter\n\t↳ MasterVC.activeProject-didSet")
                return
            }
            projectPresenter.loadProject(activeProj)
        }
    }
    
    // FIXME: Maybe implement project/view history so back and forward buttons can be used
    func prepareChange(to project: Project) {
        print("preparing project change -- MasterVC.preppareChange")
        if lastActiveProject == nil {
            lastActiveProject = activeProject
        }
        activeProject = project
    }
    
    func commitChange() {
        print("commiting change -- MasterVC.preppareChange")
        lastActiveProject = nil
    }
    
    func cancelChange() {
        // FIXME: in DataVC need to reslect last selected reading
        print("cancelng change -- MasterVC.preppareChange")
        activeProject = lastActiveProject
        lastActiveProject = nil
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    /// Outlet to the container view in which the various view 
    /// controllers will be presented
    @IBOutlet weak var containerView: UIView!

    /// outlet to a view containing a label used to indicate the current experiment name and 
    /// a label used to indicate details about the current experiment
    @IBOutlet weak var headerView: ExperimentHeaderView!
    
    @IBOutlet weak var instrumentButton: UIBarButtonItem!
    @IBOutlet weak var instrumentAlertView: InstrumentStatusView!
    
    @IBOutlet weak var instrumentButtonToAlertViewFixedSpace: UIBarButtonItem!
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
    
    var bluetoothManager: CBInstrumentCentralManager!
    
    override func viewDidLoad() {
        print("at top! \n\t↳ MasterVC.viewDidLoad")
        super.viewDidLoad()
        
        // add the primary view controllers to the ```viewControllers``` array in the same order they appear in the segmented control; using closures here to preserve lazy loading
        viewControllers.append({ return self.projectViewController })
        viewControllers.append({ return self.dataViewController })
        viewControllers.append({ return self.plotViewController })
        
        //create test data
        TestDataGenerator.initialDate = Date()
        TestDataGenerator.numReadings = 40
        let newProject = TestDataGenerator.createProject()
        activeProject = newProject
//
//        for _ in 0...150 {
//            _ = TestDataGenerator.createProject()
//            // print("\(i): \(p.dateSection.header): --> \(Formatter.monDayYr.string(from: p.editDate))")
//        }
//        
        
        for dateSection in DateSection.sectionArray {
            print("\(dateSection.header) : \(Formatter.monDayYrHrMin.string(from: dateSection.date))")
        }
        // begin by loading the initial view controller
        let firstViewIndex = 0 // 0, 1, or 2
        let firstController = viewControllers[firstViewIndex]()
        add(asChildViewController: firstController)
        if let projectPresenter = firstController as? ProjectPresenter {
            print("loading project into child view controller")
            projectPresenter.loadProject(activeProject)
        }

        // save test data
        do {
            try AppDelegate.viewContext.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save.\nSAVING ERROR: \(error), \(error.userInfo)")
        }
        
        // instantiate bluetooth manager..begins scanning if BLE is on
        bluetoothManager = CBInstrumentCentralManager(withReporter: instrumentAlertView)
        bluetoothManager.databaseDelegate = self
        
        // setup instrument alert view
        instrumentAlertView.setup()
        
        // set experiment title and subtitle
//        headerView.mainText = "A Dope Experiment Title"
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM dd, YYYY"
//        headerView.subText = formatter.string(from: Date())
        
        // move instrument alert view a bit closer to instrument button
        instrumentButtonToAlertViewFixedSpace.width = -5
        if Project.refreshAllDateSections() {
            do {
                try AppDelegate.viewContext.save()
                print("saved")
            } catch let error as NSError {
                print("Could not save.\nSAVING ERROR: \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Database Delegate Functions
    func add(dataPoint: DataPoint) {
        let reading = Reading(fromDataPoints: [dataPoint])
        reading.project = activeProject
        if let tagType = dataPoint.instrumentDataPoint?.tag.type.description,
            let tagIndex = dataPoint.instrumentDataPoint?.tag.index {
            
            reading.title = "\(tagType)-\(tagIndex)"
        }
        do {
            try AppDelegate.viewContext.save()
            print("saved \n\t↳ MasterVC.add(dataPoint:)")
        } catch let error as NSError {
            print("Could not save.\nSAVING ERROR: \(error), \(error.userInfo)")
        }
        
    }
    //------------------------------------
    
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        presentedViewController?.dismiss(animated: false, completion: nil)
        instrumentAlertView.isGrayedOut = false
        let newVC = segue.destination
        newVC.popoverPresentationController?.delegate = self

        guard let id = segue.identifier else {
            print("No segue ID, cannot prepare for segue.")
                    return
        }
        print("Segue ID: \(id)")
        
        switch id {
        case "master.segue.instrumentPop":
            let popoverVC = segue.destination as! PopoverNavigationController
            popoverVC.delegates[instrumentConnectionVCDelegateKey] = bluetoothManager as InstrummentConnectionViewControllerDelegate
            instrumentAlertView.isGrayedOut = true
            popoverVC.performSegue(withIdentifier: "popover.segue.instrument", sender: popoverVC)
            break
        case "master.segue.projectsPop":
            let popoverVC = segue.destination as! PopoverNavigationController
            popoverVC.delegates[projectChangerDelegateKey] = self as ProjectChangerDelegate
            popoverVC.performSegue(withIdentifier: "popover.segue.projects", sender: popoverVC)

        case "master.segue.addPop":
            let popoverVC = segue.destination as! PopoverNavigationController
            popoverVC.delegates[projectChangerDelegateKey] = self as ProjectChangerDelegate
            popoverVC.performSegue(withIdentifier: "popover.segue.add", sender: popoverVC)
            // FIXME: need to more smoothly gray out the segmented control, figure out how to change passthrough views
            segmentedControl.isEnabled = false
            segmentedControl.tintColor = .darkGray
            instrumentAlertView.isGrayedOut = true
            
            break
        case "master.segue.exportPop":
            let exportVC = segue.destination as! ExportPopoverViewController
            exportVC.project = activeProject
            exportVC.documentControllerPresenter = self
            break
        default:
            break
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
//        print("--MasterVC.popoverShouldDismiss")
        instrumentAlertView.isGrayedOut = false
        segmentedControl.isEnabled = true
        segmentedControl.tintColor = _UIBlue
        commitChange()
        return true;
    }
    
    
    // MARK: Document Controller Functions
    var documentController: UIDocumentInteractionController?
    
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    func presentDocController() {
        guard let dc = documentController else {
            print("no Document Controller! \n\t↳ MasterVC.presentDocConroller")
            return
        }
        dc.presentOptionsMenu(from: exportButton, animated: true)
    }
    
    
    func prepareDocController(withURL url: URL) {
        documentController = UIDocumentInteractionController(url: url)
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
        let newController = viewControllers[segmentedControlIndex]()
        if let projectPresenter = newController as? ProjectPresenter {
            print("loading project into child view controller  -- MasterVC.updateContainerView")
            projectPresenter.loadProject(activeProject)
        }
        let oldController = viewControllers[index]()
        oldController.beginAppearanceTransition(false, animated: true)
        newController.beginAppearanceTransition(true, animated: true)
        remove(asChildViewController: oldController)
        add(asChildViewController: newController)
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

