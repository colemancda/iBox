//
//  DrivesViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData

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
        
        // register section header nib
        self.tableView.registerNib(UINib(nibName: "ATAInterfaceTableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ATAInterfaceTableViewHeaderView")
        
        if self.configuration != nil {
            
            // create fetched results controller
            self.fetchedResultsController = self.fetchedResultsControllerForConfiguration(self.configuration!)
            
            // fetch and load UI
            self.fetchedResultsController!.performFetch(nil)
        }
    }
    
    // MARK: - Actions
    
    func irqStepperValueDidChange(sender: UIStepper) {
        
        // get model object
        let section = self.fetchedResultsController!.sections![sender.tag] as [Drive]
        let drive = section.first!
        let ataInterface = drive.ataInterface
        
        // set model object
        ataInterface.irq = Int(sender.value)
        
        // get header view
        let headerView = self.tableView.headerViewForSection(sender.tag) as ATAInterfaceTableViewHeaderView
        
        // set up header view
        headerView.irqLabel.text = NSLocalizedString("IRQ", comment: "IRQ") + " \(ataInterface.irq.integerValue)"
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
            
            // conditionaly enable add button
            if let addButton = self.navigationItem.rightBarButtonItem {
                
                // also enable or disable add button
                if numberOfSections < 4 {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
                else {
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }
            }
            
            // return number of section
            return numberOfSections
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController!.sections![section] as [Drive]
        
        return section.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let DriveCellIdentifier = "DriveCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DriveCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ATAInterfaceTableViewHeaderView") as ATAInterfaceTableViewHeaderView
        
        // get model object
        let sectionArray = self.fetchedResultsController!.sections![section] as [Drive]
        let drive = sectionArray.first!
        let ataInterface = drive.ataInterface;
        
        // configure header view
        headerView.ataLabel.text = NSLocalizedString("ATA Interface", comment: "ATA Interface") + " \(ataInterface.id.integerValue)"
        headerView.irqLabel.text = NSLocalizedString("IRQ", comment: "IRQ") + " \(ataInterface.irq.integerValue)"
        headerView.irqStepper.value = ataInterface.irq.doubleValue
        headerView.irqStepper.addTarget(self, action: "irqStepperValueDidChange:", forControlEvents: UIControlEvents.ValueChanged)
        headerView.irqStepper.tag = section
        
        return headerView
    }
    
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
    
    // MARK: - Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if identifier == "newDriveSegue" {
            
            // only 4 ATA interfaces max
            if self.configuration!.ataInterfaces?.count > 4 {
                
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newDriveSegue" {
            
            // find or create ata interface for new drive
            
            var ataInterface: ATAInterface?
            
            // no interfaces yet
            if self.configuration!.ataInterfaces?.count == 0 || self.configuration!.ataInterfaces?.count == nil {
                
                ataInterface = NSEntityDescription.insertNewObjectForEntityForName("ATAInterface", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as? ATAInterface
                ataInterface!.configuration = self.configuration!
            }
            
            // only support 1 ATA interface for now...
            else {
                
                // TODO: support multiple ATA interfaces
            }
            
            // create new drive
            let newDrive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as Drive
            
            // set ATA interface
            newDrive.ataInterface = ataInterface!
            
            // set model object on VC
            let driveEditorVC = segue.destinationViewController as DriveEditorViewController
            
            driveEditorVC.drive = newDrive
        }
    }
    
    
}

// MARK: - UI Classes

class ATAInterfaceTableViewHeaderView: UITableViewHeaderFooterView {
    
    // Use to bind to IB, but remove for compiling
    //@IBOutlet var contentView: UIView!
    
    @IBOutlet weak var ataLabel: UILabel!
    
    @IBOutlet weak var irqLabel: UILabel!
    
    @IBOutlet weak var irqStepper: UIStepper!
    
}