//
//  DriveEditorViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData

class DriveEditorViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var drive: Drive? {
        
        didSet {
            
            if drive != nil {
                
                let driveEntity = DriveEditorViewControllerDriveEntity(rawValue: drive!.entity.name!)!
                
                self.updateTableViewCellLayoutForEntity(driveEntity)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var tableViewCellLayout = [[DriveEditorViewControllerTableViewCellItem]]()
    
    // MARK: - Private Methods
    
    private func updateTableViewCellLayoutForEntity(entity: DriveEditorViewControllerDriveEntity) {
        
        // create layout based on entity
        
        switch entity {
            
        case .CDRom:
            
            self.tableViewCellLayout = [[.FileName], [.DiscInserted]]
            
        case .HardDiskDrive:
            
            self.tableViewCellLayout = [[.FileName], [.Heads, .Cylinders, .SectorsPerTrack]]
        }
        
        // reload UI
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func done(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchFlipped(sender: UISwitch) {
        
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.tableViewCellLayout.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // get model object
        let sectionArray = self.tableViewCellLayout[section]
        
        return sectionArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get model object
        let sectionArray = self.tableViewCellLayout[indexPath.section]
        let cellItem = sectionArray[indexPath.row]
        
        // get and configure cell
        switch cellItem {
            
        case .FileName:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DriveEditorViewControllerTableViewCellReusableIdentifier.FileNameCell.rawValue, forIndexPath: indexPath) as TextFieldCell
            
            cell.titleLabel.text = NSLocalizedString("File Name", comment: "File Name")
            
            cell.textField.text = self.drive!.fileName
            
            return cell
            
        case .DiscInserted:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DriveEditorViewControllerTableViewCellReusableIdentifier.SwitchCell.rawValue, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel.text = NSLocalizedString("Disc Inserted", comment: "Disc Inserted")
            
            /*
            let switchControl = UISwitch()
            switchControl.addTarget(self, action: "switchFlipped:", forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = switchControl
            */
            
            (cell.accessoryView as UISwitch).on = (self.drive as CDRom).discInserted.boolValue
            
            return cell

        case .Heads:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DriveEditorViewControllerTableViewCellReusableIdentifier.NumberInputCell.rawValue, forIndexPath: indexPath) as TextFieldCell
            
            cell.titleLabel.text = NSLocalizedString("Headers", comment: "Headers")
            
            cell.textField.text = "\((self.drive as HardDiskDrive).heads)"
            
            return cell
            
        case .Cylinders:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DriveEditorViewControllerTableViewCellReusableIdentifier.NumberInputCell.rawValue, forIndexPath: indexPath) as TextFieldCell
            
            cell.titleLabel.text = NSLocalizedString("Cylinders", comment: "Cylinders")
            
            cell.textField.text = "\((self.drive as HardDiskDrive).cylinders)"
            
            return cell
            
        case .SectorsPerTrack:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DriveEditorViewControllerTableViewCellReusableIdentifier.NumberInputCell.rawValue, forIndexPath: indexPath) as TextFieldCell
            
            cell.titleLabel.text = NSLocalizedString("Sectors per Track", comment: "Sectors per Track")
            
            cell.textField.text = "\((self.drive as HardDiskDrive).sectorsPerTrack)"
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0:
            
            return NSLocalizedString("Info", comment: "Info")
            
        case 1:
            
            let driveEntity = DriveEditorViewControllerDriveEntity(rawValue: drive!.entity.name!)!
            
            switch driveEntity {
                
            case .CDRom: return NSLocalizedString("CDROM Configuration", comment: "CDROM Configuration")
                
            case .HardDiskDrive : return NSLocalizedString("HDD Configuration", comment: "HDD Configuration")
                
            }
            
        default: return "Section"
            
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        
    }
}

// MARK: - Enumerations

private enum DriveEditorViewControllerDriveEntity: String {
    
    case CDRom = "CDRom"
    case HardDiskDrive = "HardDiskDrive"
}

private enum DriveEditorViewControllerTableViewCellItem {
    
    case FileName, DiscInserted, Heads, Cylinders, SectorsPerTrack
}

private enum DriveEditorViewControllerTableViewCellReusableIdentifier: String {
    
    case FileNameCell = "FileNameCell"
    case SwitchCell = "SwitchCell"
    case NumberInputCell = "NumberInputCell"
}