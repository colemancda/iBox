//
//  DrivesViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData

private let DriveCellIdentifier = "DriveCell"

class DrivesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var configuration: Configuration? {
        didSet {
            
            if configuration != nil && self.isViewLoaded() {
                
                // create fetched results controller
                self.fetchedResultsController = self.fetchedResultsControllerForConfiguration(self.configuration!)
                
                // fetch and load UI
                self.fetchedResultsController!.performFetch(nil)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.configuration != nil {
            
            // create fetched results controller
            self.fetchedResultsController = self.fetchedResultsControllerForConfiguration(self.configuration!)
            
            // fetch and load UI
            self.fetchedResultsController!.performFetch(nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchedResultsControllerForConfiguration(configuration: Configuration) -> NSFetchedResultsController {
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Drive");
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "master", ascending: false)]
        
        fetchRequest.predicate = NSPredicate(format: "ataInterface.configuration == %@", configuration)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Store.sharedInstance.managedObjectContext, sectionNameKeyPath: "ataInterface.id", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        // return fetched results controller
        return fetchedResultsController
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let drive = self.fetchedResultsController?.objectAtIndexPath(indexPath) as Drive
        
        // set type label
        if drive.master.boolValue {
            
            cell.textLabel.text = NSLocalizedString("Master", comment: "Master")
        }
        else {
            
            cell.textLabel.text = NSLocalizedString("Slave", comment: "Slave")
        }
        
        
        // set media label
        switch drive.entity.name! {
        case "CDRom": cell.detailTextLabel?.text = NSLocalizedString("CDROM", comment: "CDROM")
        case "HardDiscDrive": cell.detailTextLabel?.text = NSLocalizedString("HDD", comment: "HDD")
        default: cell.detailTextLabel?.text = NSLocalizedString("Unknown", comment: "Unknown")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let numberOfSections = self.fetchedResultsController?.sections?.count {
            
            return numberOfSections
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController!.sections![section] as [Drive]
        
        return section.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DriveCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the model object
        let drive = self.fetchedResultsController?.objectAtIndexPath(indexPath) as Drive
        
        // delete
        Store.sharedInstance.managedObjectContext.deleteObject(drive)
        
        // save
        
        var error: NSError?
        
        Store.sharedInstance.managedObjectContext.save(&error)
        
        if error != nil {
            
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Could not delete drive.", comment: "Could not delete drive.") + " \\(\(error!.localizedDescription)\\)", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
