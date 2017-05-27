//
//  ViewController.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/14/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

protocol ProjectPresenter {
    func loadProject(_ project: Project)
}

class MasterViewController: UIViewController, UIPopoverPresentationControllerDelegate, ProjectChangerDelegate, DatabaseDelegate, DocumentControllerPresenter {
    
    @IBOutlet weak var createImage: UIImageView!
    @IBOutlet weak var editImage: UIImageView!
    
    var dataViewController: DataViewController? {
        return childViewControllers.first as? DataViewController
    }
    
    var newProject: Project? = nil
    var activeProject: Project! {
        didSet {
            guard oldValue != activeProject else {
                // same project
                return
            }
//            print("didSet active project -- MasterVC")
            guard let activeProj = activeProject else {
                print("WARNING: just set the active project to nil. --MasterVC")
                createImage.isHidden = false
                editImage.isHidden = false
                return
            }
            
            createImage.isHidden = true
            editImage.isHidden = true
            print("Set `activeProject` to: \(activeProj.title)\n\t↳ MasterVC.activeProject-didSet")
            headerView.mainText = activeProj.title
            headerView.titleField.text = activeProj.title
            var subText: String? = nil
            if let subText1 = Formatter.monDayYr.string(fromOptional: activeProj.editDate) {
                subText = subText1
            }
            if let subText2 = activeProj.notebookReference {
                if subText == nil {
                    subText = subText2
                } else {
                    subText = subText! + "  —  " + subText2
                }
            }
            headerView.subText = subText
            
            guard let projectPresenter = childViewControllers.first as? ProjectPresenter else {
                print("could not load project presenter\n\t↳ MasterVC.activeProject-didSet")
                return
            }
            projectPresenter.loadProject(activeProj)
        }
    }
    
    // FIXME: Maybe implement project/view history so back and forward buttons can be used
    func prepareChange(to project: Project) {
        print("Preparing project change!\n\t↳ MasterVC.preppareChange")
        newProject = project
    }
    
    func commitChange() {
        print("Commiting project change!\n\t↳ MasterVC.preppareChange")
        if let p = newProject {
            activeProject = p
            newProject = nil
        } else {
            return
        }
    }
    
    
    
    func cancelChange() {
        // FIXME: in DataVC need to reslect last selected reading
        guard newProject != nil else {
            print("No project change to cancel!\n\t↳ MasterVC.preppareChange")
            return
        }
        print("Canceling project change!\n\t↳ MasterVC.preppareChange")
        newProject = nil
    }
    
    /// Outlet to the container view in which the various view 
    /// controllers will be presented
    @IBOutlet weak var containerView: UIView!

    /// outlet to a view containing a label used to indicate the current experiment name and 
    /// a label used to indicate details about the current experiment
    @IBOutlet weak var headerView: ExperimentHeaderView!
    
    @IBOutlet weak var instrumentButton: UIBarButtonItem!
    @IBOutlet weak var instrumentAlertView: InstrumentStatusView!
    
    @IBOutlet weak var instrumentButtonToAlertViewFixedSpace: UIBarButtonItem!

    @IBOutlet weak var navItem: UINavigationItem!
    
    /// an array of closures that each return the primary view controllers
    var viewControllers: [()->UIViewController] = []
    
    /// index of the current segmented control selection
    var segmentedControlIndex = 0
    
    var bluetoothManager: CBInstrumentCentralManager!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       print("at top! \n\t↳ MasterVC.viewWillAppear")
        
        navItem.titleView?.autoresizesSubviews = false
    }
    
    override func viewDidLoad() {
        print("at top! \n\t↳ MasterVC.viewDidLoad")
        super.viewDidLoad()
        
        print(navigationController?.navigationBar.frame ?? CGRect())
        
        headerView.backgroundAccent.isHidden = true
        headerView.titleField.isEnabled = false

        let notifCenter = NotificationCenter.default
        let _ = notifCenter.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main, using: {
            note in
//            print("in notification...Context did save...\n\t↳ NotificationCenter")
            guard let activeProj = self.activeProject else {
                return
            }
            self.headerView.titleField.text = activeProj.title
            var subText: String? = nil
            if let subText1 = Formatter.monDayYr.string(fromOptional: activeProj.editDate) {
                subText = subText1
            }
            if let subText2 = activeProj.notebookReference {
                if subText == nil {
                    subText = subText2
                } else {
                    subText = subText! + "  —  " + subText2
                }
            }
            self.headerView.subText = subText
        })
        
        
        //create test data
        TestDataGenerator.initialDate = Date()
        TestDataGenerator.numReadings = 1
//        let newProject = TestDataGenerator.createProject()
        
//        for _ in 0...50 {
//            _ = TestDataGenerator.createProject()
//            // print("\(i): \(p.dateSection.header): --> \(Formatter.monDayYr.string(from: p.editDate))")
//        }

        // save test data
//        do {
//            try AppDelegate.viewContext.save()
//            print("saved context! \n\t↳ MasterVC.viewDidLoad()")
//        } catch let error as NSError {
//            print("Could not save.\nSAVING ERROR: \(error), \(error.userInfo) \n\t↳ MasterVC.viewDidLoad()")
//        }
        
        
        // set new project as active project
//        activeProject = newProject
//        (childViewControllers.first as! DataViewController).project = activeProject
        
        // instantiate bluetooth manager..begins scanning if BLE is on
        bluetoothManager = CBInstrumentCentralManager(withReporter: instrumentAlertView)
        bluetoothManager.databaseDelegate = self
        
        
        // datapoint simulation
        TestDataGenerator.instrumentManagerBLE = bluetoothManager
        TestDataGenerator.setupBLESimulation()

        
        // setup instrument alert view
        instrumentAlertView.setup()
        
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
        
        
        if activeProject == nil {
            createImage.isHidden = false
            editImage.isHidden = false
        } else {
            createImage.isHidden = true
            editImage.isHidden = true
        }
        
//        dataViewController = childViewControllers.first as? DataViewController
    }

    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
       print("`sort` button pressed! \n\t↳ MasterVC")
        let pop = UIAlertController(title: nil, message: "Sort the readings by:", preferredStyle: .actionSheet)
        pop.addAction(UIAlertAction(title: "Type", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Date", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Name", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        pop.popoverPresentationController?.barButtonItem = sortButton
        present(pop, animated: true, completion: nil)
    }
    
    
    @IBAction func layoutButtonPressed(_ sender: UIBarButtonItem) {
        print("`layout` button pressed! \n\t↳ MasterVC")
        let pop = UIAlertController(title: nil, message: "Show Data Specific To:", preferredStyle: .actionSheet)
        pop.addAction(UIAlertAction(title: "Bradford Assay", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Cell Density", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Nucleic Acid", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "General", style: .default, handler: addAction))
        pop.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        pop.popoverPresentationController?.barButtonItem = sender
        present(pop, animated: true, completion: nil)
    }
    
//    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
//        popoverPresentationController.barButtonItem = sortButton
//    }
    
    func addAction(_ action: UIAlertAction) {
        guard let title = action.title else {
            return
        }
        let dataVC = (childViewControllers.first as! DataViewController).masterVC!
        switch title {
        case "Type":
            dataVC.sortSetting = .type
        case "Date":
            dataVC.sortSetting = .date
        case "Name":
            dataVC.sortSetting = .name
        case "Bradford Assay":
            dataVC.cellViewType = .bradfordView
        case "Cell Density":
            dataVC.cellViewType = .cellDensityView
        case "General":
            dataVC.cellViewType = .generalView
        case "Nucleic Acid":
            dataVC.cellViewType = .nucleicAcidView
        default:
            break
        }
    }
    // MARK: - Database Delegate Functions
    func add(dataPoint: DataPoint) {
        var reading: Reading
        let makeNewReading: () -> Reading = {
            let reading = Reading(fromDataPoints: [dataPoint])
            reading.project = self.activeProject
            if let tagType = dataPoint.instrumentDataPoint?.tag.type.description,
                let tagIndex = dataPoint.instrumentDataPoint?.tag.index {
                reading.title = "\(tagType)-\(tagIndex)"
            }
            return reading
        }

        if let idp = dataPoint.instrumentDataPoint, let sessionID = idp.connectionSessionIDDB {

            let request: NSFetchRequest<DataPoint> = DataPoint.fetchRequest()

            let predicate = NSPredicate(
                format: "(instrumentDataPoint.connectionSessionIDDB MATCHES %@) && (instrumentDataPoint.tagTypeDB == %@) && (instrumentDataPoint.tagIndexDB == %@) && (reading.project == %@)",
                sessionID,
                idp.tagTypeDB as NSNumber,
                idp.tagIndexDB as NSNumber,
                activeProject
            )
        
            let sort = NSSortDescriptor(key: "timestampDB", ascending: false, selector: #selector(NSDate.compare(_:)))
    
            request.predicate = predicate
      
            request.sortDescriptors = [sort]
            do {
          
                let result: [DataPoint] = try AppDelegate.viewContext.fetch(request)
        
                if result.count > 0 {
                    print("Adding a repeat reading! \n\t↳ MasterVC.add(datapoint:)")
                    result[0].reading?.addToDataPoints(dataPoint: dataPoint)
                    reading = result[0].reading ?? makeNewReading()
//                    dataViewController?.lastUpdatedReading = reading
                } else {
                    print("No repeats found, adding a new reading! \n\t↳ MasterVC.add(datapoint:)")
                    reading = makeNewReading()
//                    dataViewController?.lastUpdatedReading = reading
                }
            } catch {
                print("ERROR: Could not fetch!\n\t↳ MasterVC.add(datapoint:)")
                reading = makeNewReading()
//                dataViewController?.lastUpdatedReading = reading
            }
        } else {
            print("ERROR: the dataPoint's instrumentDP or connectionSessionID was nil... \n\t↳ MasterVC.add(datapoint:)")
            reading = makeNewReading()
//            dataViewController?.lastUpdatedReading = reading
        }
        
        if reading.type == .blank {
            updateBlank(with: reading)
            
        } else {
            dataPoint.baselineValue = activeProject.baselineValue ?? 0
        }
//
//        Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: {
//            _ in
//            
//        })
        
        
        do {
            try AppDelegate.viewContext.save()
            print("Saved context. \n\t↳ MasterVC.add(dataPoint:)")
            self.dataViewController?.lastUpdatedReading = reading
        } catch let error as NSError {
            print("Could not save.\nSAVING ERROR: \(error), \(error.userInfo)")
        }
        
        
        
    }
    //------------------------------------
    
    func updateBlank(with reading: Reading) {
        guard reading.type == .blank, let val = reading.rawValue else {
            print("Cannot update blank with a reading of non-blank type or with no points. \n\t↳ MasterVC.updateBlank(with:)")
            return
        }
        
        if let p = reading.project {
            let request: NSFetchRequest<DataPoint> = DataPoint.fetchRequest()
            // FIXME: be more selective
            let predicate = NSPredicate(format: "(reading.project == %@) && (baselineValueDB == %@)", p, NSNumber(value: 0))
            request.predicate = predicate
            do {
                let result: [DataPoint] = try AppDelegate.viewContext.fetch(request)
                if result.count > 0 {
                    print("BLAAAAAAAAAANK: Setting new blank for points in the project w/o a blank! \n\t↳ MasterVC.updateBlank(with:)")
                    for point in result {
                        point.baselineValue = val
                    }
                    (childViewControllers.first as? DataViewController)?.masterVC?.dataTableView.reloadData()
                    do {
                        try AppDelegate.viewContext.save()
                        print("Saved context. \n\t↳ MasterVC.updateBlank(with:)")
                    } catch let error as NSError {
                        print("ERROR: Could not save. Error description: \(error.debugDescription)\n\t↳ MasterVC.updateBlank(with:)")
                    }
                    
                } else {
                    print("Cound not find points in project! \n\t↳ MasterVC.updateBlabk(with:)")
                }
            } catch {
                print("ERROR: Could not fetch!\n\t↳ MasterVC.updateBlank(with:)")
            }
        }
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
//            segmentedControl.isEnabled = false
//            segmentedControl.tintColor = .darkGray
            instrumentAlertView.isGrayedOut = true
            
            break
        case "master.segue.exportPop":
            let popoverVC = segue.destination as! PopoverNavigationController
            popoverVC.project = activeProject
            popoverVC.delegates[docControllerPresenterKey] = self as DocumentControllerPresenter
            popoverVC.performSegue(withIdentifier: "popover.segue.export", sender: popoverVC)
            break
            
        case "master.segue.infoPop":
            let popoverVC = segue.destination as! PopoverNavigationController
            popoverVC.project = activeProject
//            self.headerView.backgroundAccent.layer.backgroundColor = UIColor.white.cgColor
//            self.headerView.backgroundAccent.layer.cornerRadius = 7
//            UIView.transition(
//                with: headerView,
//                duration: 0.5,
//                options: UIViewAnimationOptions.transitionCrossDissolve,
//                animations: {
//                    self.instrumentAlertView.isGrayedOut = true
//                    self.headerView.backgroundAccent.isHidden = false
//                    self.headerView.subLabel.textColor = .lightGray
//                    self.headerView.backgroundAccent.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                    self.headerView.titleField.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                },
//                completion: {
//                    if $0 {
//                        self.headerView.titleField.isEnabled = true
//                        
////                        self.headerView.titleField.becomeFirstResponder()
//                    }
//                }
//            )
            popoverVC.performSegue(withIdentifier: "popover.segue.info", sender: popoverVC)
//            popoverVC.popoverPresentationController?.passthroughViews = [headerView, headerView.backgroundAccent, headerView.titleField]
        default:
            break
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
//        print("--MasterVC.popoverShouldDismiss")
        instrumentAlertView.isGrayedOut = false
//        headerView.titleField.isEnabled = false
//        
//        UIView.transition(
//            with: headerView.backgroundAccent,
//            duration: 0.6,
//            options: UIViewAnimationOptions.transitionCrossDissolve,
//            animations: {
//                self.headerView.titleField.borderStyle = .none
//                self.headerView.subLabel.textColor = .black
//                self.headerView.backgroundAccent.isHidden = true
//                self.headerView.backgroundAccent.transform = CGAffineTransform(scaleX: 1, y: 1)
//                self.headerView.titleField.transform = CGAffineTransform(scaleX: 1, y: 1)
//            },
//            completion: nil
//        )
        
//        if let text = headerView.titleField.text {
//            if text != activeProject.title {
//                activeProject.title = text
//                try? AppDelegate.viewContext.save()
//            }
//        }
//        segmentedControl.isEnabled = true
//        segmentedControl.tintColor = _UIBlue
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

