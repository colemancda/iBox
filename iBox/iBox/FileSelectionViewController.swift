//
//  FileSelectionViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import BochsKit
import MBProgressHUD

private let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL

class FileSelectionViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var files = [NSURL]()
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh(self)
    }
    
    // MARK: - Methods
    
    func selectedFile() -> NSURL? {
        
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
            
            return self.files[selectedIndexPath.row]
        }
        
        return nil
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject) {
        
        self.files = NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles | .SkipsPackageDescendants | .SkipsSubdirectoryDescendants, error: nil)! as [NSURL]
        
        self.tableView.reloadData()
    }
    
    @IBAction func createNewImage(sender: AnyObject) {
        
        // create alert controller
        let alertController = UIAlertController(title: NSLocalizedString("Create New HDD Image", comment: "Create New HDD Image Alert Controller Title"),
            message: NSLocalizedString("Specify a name", comment: "Create New HDD Image Alert Controller Message"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // add text field
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            
            textField.text = "hddImage"
        }
        
        // add create and cancel button
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
            
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: "Create"), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            
            // dismiss and show progress view
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                // configure HUD
                progressHUD.mode = 
            })
        }))
        
        // show
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellReusableIdentifier.FileNameCell.rawValue, forIndexPath: indexPath) as UITableViewCell
        
        // get model object
        let file = self.files[indexPath.row]
        
        // configure cell
        cell.textLabel.text = file.lastPathComponent
        
        return cell
    }
}

// MARK: - Private Enumerations

private enum TableViewCellReusableIdentifier: String {
    
    case FileNameCell = "FileNameCell"
}