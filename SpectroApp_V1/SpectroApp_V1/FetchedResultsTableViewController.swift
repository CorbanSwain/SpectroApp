//
//  FetchedResultsTableViewController.swift
//  SmashtagA5
//
//  Created by Paul Hegarty on 2/3/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsTableViewController: UIViewController, NSFetchedResultsControllerDelegate
{
    var tableView: UITableView!
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? DataTableViewCell, cell.titleField.isEditing {
                print("returning before reloading row!\n\t↳ FetchedResultsTableVC.controller(...didChange)")
                return
            }
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            if let cell = tableView.cellForRow(at: indexPath!) as? DataTableViewCell, cell.titleField.isEditing {
                print("returning before moving row!\n\t↳ FetchedResultsTableVC.controller(...didChange)")
                return
            }
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
