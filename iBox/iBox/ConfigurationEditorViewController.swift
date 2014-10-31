//
//  ConfigurationEditorViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 10/31/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit

class ConfigurationEditorViewController: UITableViewController {
    
    // MARK: - Properties
    
    
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func save(sender: AnyObject) {
        
        
    }
        
}