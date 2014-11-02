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
    
    private let maxATAInterfaces = ((Store.sharedInstance.managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName["Configuration"] as NSEntityDescription).relationshipsByName["ataInterfaces"] as NSRelationshipDescription).maxCount
    
    private let maxDrivesPerATAInterface = ((Store.sharedInstance.managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName["ATAInterface"] as NSEntityDescription).relationshipsByName["drives"] as NSRelationshipDescription).maxCount
    
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
        let sectionInfo = self.fetchedResultsController!.sections![sender.tag] as NSFetchedResultsSectionInfo
        
        let section = sectionInfo.objects as [Drive]
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
        case "HardDiskDrive": cell.detailTextLabel?.text = NSLocalizedString("HDD", comment: "HDD")
        default: cell.detailTextLabel?.text = NSLocalizedString("Unknown", comment: "Unknown")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let numberOfSections = self.fetchedResultsController?.sections?.count {
            
            // conditionaly enable add button
            if let addButton = self.navigationItem.rightBarButtonItem {
                
                // also enable or disable add button
                if numberOfSections < self.maxATAInterfaces {
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
        
        let sectionInfo = self.fetchedResultsController!.sections![section] as NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
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
        let sectionInfo = self.fetchedResultsController!.sections![section] as NSFetchedResultsSectionInfo
        let sectionArray = sectionInfo.objects as [Drive]
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
            if self.configuration!.ataInterfaces?.count > self.maxATAInterfaces {
                
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newDriveSegue" {
            
            // create new drive
            let newDrive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as Drive
            
            // find or create ata interface for new drive
            
            var ataInterface: ATAInterface?
            
            // no interfaces yet
            if self.configuration!.ataInterfaces?.count == 0 || self.configuration!.ataInterfaces?.count == nil {
                
                ataInterface = NSEntityDescription.insertNewObjectForEntityForName("ATAInterface", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as? ATAInterface
                ataInterface!.configuration = self.configuration!
            }
            
            // ATA interfaces exist
            else {
                
                // find latest ATA interface
                
                let fetchRequest = NSFetchRequest(entityName: "ATAInterface")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "configuration == %@", self.configuration!)
                
                var fetchError: NSError?
                let fetchResult = Store.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest, error: &fetchError)
                
                assert(fetchError == nil, "Error occurred while fetching from store. (\(fetchError?.localizedDescription))")
                
                let newestATAInterface = fetchResult!.last as ATAInterface
                
                // get number of existing drives
                var numberOfDrivesInNewestATAInterface = 0
                
                if newestATAInterface.drives != nil {
                    
                    numberOfDrivesInNewestATAInterface = newestATAInterface.drives!.count
                }
                
                // set or create ATA interface
                switch numberOfDrivesInNewestATAInterface {
                    
                    // already has slave and master
                case maxDrivesPerATAInterface:
                    
                    // create new ATA interface
                    ataInterface = NSEntityDescription.insertNewObjectForEntityForName("ATAInterface", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as? ATAInterface
                    ataInterface!.configuration = self.configuration!
                    ataInterface!.id = self.configuration!.ataInterfaces!.count
                    
                    // doesnt have any drives
                case 0:
                    
                    ataInterface = newestATAInterface
                    
                    // newly created drives are master by default
                    
                    // add as slave
                default:
                    
                    ataInterface = newestATAInterface
                    
                    newDrive.master = false
                }
                
            }
                
            // set drive interface
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