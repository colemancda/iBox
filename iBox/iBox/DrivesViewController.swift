//
//  DrivesViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData

private let DriveCellIdentifier = "DriveCellIdentifier"

class DrivesViewController: UITableViewController {
    
    // MARK: - Properties
    
    var configuration: Configuration? {
        didSet {
            
            if configuration != nil {
                
                self.drives = self.drivesDataSourceArrayForConfiguration(configuration!)
                
                // reload UI
                if self.isViewLoaded() {
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var drives: [Drive] = []
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // reload table view
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARK: - Private Methods
    
    private func drivesDataSourceArrayForConfiguration(configuration: Configuration) -> [Drive] {
        
        // get interfaces in configuration
        
        let interfaceFetchRequest = NSFetchRequest(entityName: "ATAInterface")
        interfaceFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        
    }
    
    private func driveAtIndexPath(indexPath: NSIndexPath) -> Drive {
        
        
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let drive = self.driveAtIndexPath(indexPath)
        
        // set type label
        
        
        
        // set media label
        switch drive.entity.name! {
            case "CDRom": cell.detailTextLabel?.text = NSLocalizedString("CDROM", comment: "CDROM")
            case "HardDiscDrive": cell.detailTextLabel?.text = NSLocalizedString("HDD", comment: "HDD")
        default: cell.detailTextLabel?.text = NSLocalizedString("Unknown", comment: "Unknown")
        }
    }
    
    // MARK: - UITableViewCellDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.drives.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
    }
}
