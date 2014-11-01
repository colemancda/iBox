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
        
        // set predicate for search text
        if searchText != nil && searchText != "" {
            
            fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", searchText!)
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Store.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        // return fetched results controller
        return fetchedResultsController
    }
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let configuration = self.configurationForIndexPath(indexPath)
        
        cell.textLabel.text = configuration.name;
    }
    
    private func configurationForIndexPath(indexPath: NSIndexPath) -> Configuration {
        
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
        
        self.configureCell(cell, forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // update the fetched results controller
        self.fetchedResultsController = self.fetchedResultsControllerForSearchText(searchText);
    }
    
    // MARK: - NSFetchedResultsController
    
    
}