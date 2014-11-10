//
//  ConfigurationEditorViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 10/31/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit

class ConfigurationEditorViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var configurationNameTextField: UITextField!
    
    @IBOutlet weak var drivesTableViewCell: UITableViewCell!
    
    @IBOutlet weak var bootDiskSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var ramLabel: UILabel!
    
    @IBOutlet weak var ramSlider: UISlider!
    
    @IBOutlet weak var ipsTextField: UITextField!
    
    @IBOutlet weak var i440fxSupportSwitch: UISwitch!
    
    @IBOutlet weak var vgaExtensionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var vgaUpdateIntervalTextField: UITextField!
    
    @IBOutlet weak var soundBlaster16Switch: UISwitch!
    
    @IBOutlet weak var dmaTimerTextField: UITextField!
    
    @IBOutlet weak var keyBoardPasteDelayTextField: UITextField!
    
    @IBOutlet weak var keyboardSerialDelayTextField: UITextField!
    
    // MARK: - Properties
    
    var configuration: Configuration? {
        didSet {
            
            if configuration != nil && self.isViewLoaded() {
                
                self.loadUI(forConfiguration: self.configuration!)
            }
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // load UI
        if configuration != nil {
            
            self.loadUI(forConfiguration: self.configuration!)
        }
    }
    
    private func loadUI(forConfiguration configuration: Configuration) {
        
        // setup UI with values from model object...
        
        configurationNameTextField.text = configuration.name
        
        switch configuration.bootDevice {
            case "cdrom": self.bootDiskSegmentedControl.selectedSegmentIndex = 0
            case "disk": self.bootDiskSegmentedControl.selectedSegmentIndex = 1
        default : self.bootDiskSegmentedControl.selectedSegmentIndex = -1
        }
        
        ramLabel.text = "RAM: \(configuration.ramSize)"
        
        ramSlider.value = configuration.ramSize.floatValue
        
        ipsTextField.text = "\(configuration.cpuIPS)"
        
        i440fxSupportSwitch.on = configuration.i440fxsupport.boolValue
        
        switch configuration.vgaExtension {
            case "vbe": self.vgaExtensionSegmentedControl.selectedSegmentIndex = 1
        default: self.vgaExtensionSegmentedControl.selectedSegmentIndex = 0
        }
        
        vgaUpdateIntervalTextField.text = "\(configuration.vgaUpdateInterval.integerValue)"
        
        soundBlaster16Switch.on = configuration.soundBlaster16.boolValue
        
        dmaTimerTextField.text = "\(configuration.dmaTimer.integerValue)"
        
        keyBoardPasteDelayTextField.text = "\(configuration.keyboardPasteDelay.integerValue)"
        
        keyboardSerialDelayTextField.text = "\(configuration.keyboardSerialDelay.integerValue)"
    }
    
    // MARK: - Actions
    
    @IBAction func save(sender: AnyObject) {
        
        assert(self.configuration != nil)
        
        let configuration = self.configuration!
        
        // get values from UI and set them to model object
        
        configuration.name = self.configurationNameTextField.text;
        
        switch self.bootDiskSegmentedControl.selectedSegmentIndex {
        case 0: configuration.bootDevice = "cdrom"
        case 1: configuration.bootDevice = "disk"
        default: configuration.bootDevice = "cdrom"
        }
        
        configuration.ramSize = UInt(self.ramSlider.value)
                
        configuration.cpuIPS = self.ipsTextField.text!.toInt()!
        
        configuration.i440fxsupport = self.i440fxSupportSwitch.on
        
        switch self.vgaExtensionSegmentedControl.selectedSegmentIndex {
        case 0: configuration.vgaExtension = "none"
        case 1: configuration.vgaExtension = "vbe"
        default: configuration.vgaExtension = "none"
        }
        
        configuration.vgaUpdateInterval = self.vgaUpdateIntervalTextField.text.toInt()!
        
        configuration.soundBlaster16 = self.soundBlaster16Switch.on
        
        configuration.dmaTimer = self.dmaTimerTextField.text.toInt()!
        
        configuration.keyboardPasteDelay = self.keyBoardPasteDelayTextField.text.toInt()!
        
        configuration.keyboardSerialDelay = self.keyboardSerialDelayTextField.text.toInt()!
        
        // save (will also validate)
        
        var error: NSError?
        
        Store.sharedInstance.managedObjectContext.save(&error);
        
        if error != nil {
            
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Could not save configuration.", comment: "Could not save configuration.") + " \\(\(error!.localizedDescription)\\)", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        // dismiss VC
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        Store.sharedInstance.managedObjectContext.rollback()
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func ramSliderValueChanged(sender: UISlider) {
                
        ramLabel.text = "RAM: \(UInt(sender.value))"
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDrives" {
            
            let drivesVC = segue.destinationViewController as DrivesViewController
            
            drivesVC.configuration = self.configuration
        }
    }
    
    
    
}