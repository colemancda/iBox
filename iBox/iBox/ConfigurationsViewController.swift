//
//  ConfigurationsViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 10/27/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData

private let ConfigurationCellIdentier = "ConfigurationCell"

class ConfigurationsViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Private Properties
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create fetched results controller
        self.fetchedResultsController = self.fetchedResultsControllerForSearchText(nil)
        
        self.fetchedResultsController!.performFetch(nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // clear search text
        self.searchBar.text = ""
    }
    
    // MARK: - Private Methods
    
    private func fetchedResultsControllerForSearchText(searchText: String?) -> NSFetchedResultsController {
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Configuration");
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // set predicate for search text
        if searchText != nil && searchText != "" {
            
            fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", searchText!)
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Store.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        // return fetched results controller
        return fetchedResultsController
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let configuration = self.configurationAtIndexPath(indexPath)
        
        cell.textLabel.text = configuration.name;
    }
    
    private func configurationAtIndexPath(indexPath: NSIndexPath) -> Configuration {
        
        return self.fetchedResultsController?.fetchedObjects![indexPath.row] as Configuration
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = self.fetchedResultsController?.fetchedObjects?.count {
            
            return count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ConfigurationCellIdentier, forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the model object
        let configuration = self.configurationAtIndexPath(indexPath)
        
        // delete
        Store.sharedInstance.managedObjectContext.deleteObject(configuration)
        
        // save
        
        var error: NSError?
        
        Store.sharedInstance.managedObjectContext.save(&error)
        
        if error != nil {
            
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Could not delete configuration.", comment: "Could not delete configuration.") + " \\(\(error!.localizedDescription)\\)", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // update the fetched results controller
        self.fetchedResultsController = self.fetchedResultsControllerForSearchText(searchText);
        
        self.fetchedResultsController!.performFetch(nil)
        
        self.tableView.reloadData()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newConfigurationSegue" {
            
            // create new configuration
            
            let newConfiguration = NSEntityDescription.insertNewObjectForEntityForName("Configuration", inManagedObjectContext: Store.sharedInstance.managedObjectContext) as Configuration
            
            let configurationEditorVC = (segue.destinationViewController as UINavigationController).viewControllers.first as ConfigurationEditorViewController
            
            configurationEditorVC.configuration = newConfiguration
        }
        
        if segue.identifier == "editConfigurationSegue" {
            
            // edit configuration
            
            let configuration = self.configurationAtIndexPath(self.tableView.indexPathForCell(sender as UITableViewCell)!)
            
            let configurationEditorVC = (segue.destinationViewController as UINavigationController).viewControllers.first as ConfigurationEditorViewController
            
            configurationEditorVC.configuration = configuration
            
        }
    }
}