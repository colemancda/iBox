//
//  DriveEditorViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit

class DriveEditorViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    
    
    // MARK: - Properties
    
    var drive: Drive?
    
    // MARK: - Actions
    
    @IBAction func done(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
