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
    
    @IBOutlet weak var cpuCoresLabel: UILabel!
    
    @IBOutlet weak var cpuCoresStepper: UIStepper!
    
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
        didSet{
            
            if configuration != nil && self.isViewLoaded() {
                
                self.mode = .Edit
                
                self.loadUI(forConfiguration: self.configuration!)
            }
        }
    }
    
    private var mode: ConfigurationEditorViewControllerMode = .Create
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // create new object if none was created
        
        
        if configuration != nil && self.isViewLoaded() {
            
            
        }
    }
    
    private func loadUI(forConfiguration configuration: Configuration) {
        
        // setup UI with values from model object...
        
        self.configurationNameTextField.text = configuration.name
        
        switch configuration.bootDevice {
            case "cdrom": self.bootDiskSegmentedControl.selectedSegmentIndex = 0
            case "hdd": self.bootDiskSegmentedControl.selectedSegmentIndex = 1
        default : self.bootDiskSegmentedControl.selectedSegmentIndex = -1
        }
        
        ramLabel.text = "RAM: \(configuration.ramSize)"
        
        ramSlider.value = configuration.ramSize.floatValue
        
        cpuCoresLabel.text = NSLocalizedString("CPU Cores: ", comment: "CPU Cores: ") + "\(configuration.cpuCount.integerValue)"
        
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
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func save(sender: AnyObject) {
        
        // get values from UI and set them to model object
        
        // validate
        
        // save
        
        // dismiss VC
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
    
    
    
}

private enum ConfigurationEditorViewControllerMode {
    
    case Create
    case Edit
}
