//
//  EmulatorViewController.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/9/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import UIKit
import CoreData
import BochsKit

private let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL

class EmulatorViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var renderContainerView: UIView!
    
    // MARK: - Properties
    
    var configuration: Configuration?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add render view
        
        self.view.addSubview(BXRenderView.sharedInstance())
        
        // start emulator
        
        NSThread.detachNewThreadSelector("startEmulator", toTarget: self, withObject: nil)
        
        NSThread.detachNewThreadSelector("startRendering", toTarget: self, withObject: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - View Layout
    
    override func viewDidLayoutSubviews() {
        
        BXRenderView.sharedInstance().frame = self.renderContainerView.frame
    }
    
    // MARK: - Methods
    
    func startEmulator() {
        
        let configFilePath = self.exportConfigurationToTemporaryFile(self.configuration!)
        
        BXEmulator.startBochsWithConfigPath(configFilePath);
    }
    
    func startRendering() {
        
        let timer = NSTimer(timeInterval: 0.01, target: self, selector: "redrawRenderer", userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        NSRunLoop.currentRunLoop().run()
    }
    
    func redrawRenderer() {
        
        BXRenderView.sharedInstance().doRedraw()
    }
    
    func exportConfigurationToTemporaryFile(configuration: Configuration) -> String {
        
        var configString = "config_interface: textconfig\n"
        configString += "display_library: nogui\n"
        configString += "megs: \(configuration.ramSize.intValue)\n"
        configString += "boot: \(configuration.bootDevice)\n"
        
        // add drives...
        
        if configuration.ataInterfaces? != nil {
            
            let interfaces = configuration.ataInterfaces!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as [ATAInterface]
            
            // add ATA interfaces
                
            for ataInterface in interfaces {
                
                configString += "ata\(ataInterface.id): enabled=1, "
                
                let drives = ataInterface.drives!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "master", ascending: false)]) as [Drive]
                
                // add IO Addresses
                
                for drive in drives {
                    
                    // get index
                    let index = (drives as NSArray).indexOfObject(drive)
                    
                    configString += "ioaddr\(index + 1)=\(drive.ioAddress), "
                }
                
                // add IRQ
                configString += "irq=\(ataInterface.irq)\n"
                
                // add drives
                
                for drive in drives {
                    
                    // master
                    var driveMasterString: String?
                    
                    if drive.master.boolValue {
                        
                        driveMasterString = "master"
                    }
                    else {
                        
                        driveMasterString = "slave"
                    }
                    
                    // type
                    var driveType:String?
                    
                    let driveEntity = DriveEntity(rawValue: drive.entity.name!)!
                    
                    switch driveEntity {
                        
                    case .CDRom: driveType = "cdrom"
                    case .HardDiskDrive: driveType = "disk"
                    }
                    
                    // path and info
                    let driveFilePath = documentsURL.URLByAppendingPathComponent(drive.fileName).path!
                    
                    configString += "ata\(ataInterface.id)-\(driveMasterString!): type=\(driveType!), path=\"\(driveFilePath)\", "
                    
                    // drive specific info
                    switch driveEntity {
                        
                    case .CDRom:
                        
                        let cdrom = drive as CDRom
                        
                        var insertedString: String?
                        
                        if cdrom.discInserted.boolValue {
                            
                            insertedString = "inserted"
                        }
                        else {
                            
                            insertedString = "ejected"
                        }
                        
                        configString += "status=\(insertedString!)"
                        
                    case .HardDiskDrive:
                        
                        let hdd = drive as HardDiskDrive
                        
                        configString += "mode=flat, cylinders=\(hdd.cylinders), heads=\(hdd.heads), spt=\(hdd.sectorsPerTrack)"
                    }
                    
                    // add newline
                    configString += "\n"
                }
            }
        }
        
        // add other parameters
        
        configString += "i440fxsupport: enabled=\(configuration.i440fxsupport.intValue)" + "\n"
        
        if configuration.soundBlaster16.boolValue {
            
            configString += "sb16: enabled = 1, midimode=1, wavemode=1, dmatimer=\(configuration.dmaTimer.integerValue)" + "\n"
        }
        
        configString += "floppy_bootsig_check: disabled=1" + "\n"
        configString += "vga_update_interval: \(configuration.vgaUpdateInterval.integerValue)" + "\n"
        configString += "vga: extension=\(configuration.vgaExtension)" + "\n"
        configString += "keyboard_serial_delay: \(configuration.keyboardSerialDelay.integerValue)" + "\n"
        configString += "keyboard_paste_delay: \(configuration.keyboardPasteDelay.integerValue)" + "\n"
        configString += "cpu: count=1, ips=\(configuration.cpuIPS.integerValue)" + "\n"
        configString += "mouse: enabled=1, type=ps2" + "\n"
        configString += "clock: sync=none, time0=local" + "\n"
        configString += "log: " + documentsURL.URLByAppendingPathComponent("log.txt").path! + "\n"
        configString += "logprefix: %i - %e%d" + "\n"
        configString += "debugger_log: -" + "\n"
        configString += "panic: action=ask"  + "\n"
        configString += "error: action=report" + "\n"
        configString += "info: action=report" + "\n"
        configString += "debug: action=ignore" + "\n"
        configString += "pass: action=fatal" + "\n"
        configString += "keyboard_mapping: enabled=0" + "\n"
        configString += "keyboard_type: mf" + "\n"
        configString += "user_shortcut: keys=none" + "\n"
        
        // add bios file paths
        
        let bochsKitBundle = NSBundle(identifier: "com.bochs.BochsKit")!
        
        let biosPath = bochsKitBundle.URLForResource("BIOS-bochs-latest", withExtension: nil)!.path!
        
        let vgaBiosPath = bochsKitBundle.URLForResource("VGABIOS-lgpl-latest", withExtension: nil)!.path!
        
        configString += "romimage: file=\"\(biosPath)\", address=0x00000 \nvgaromimage: file=\"\(vgaBiosPath)\""
        
        let path = NSTemporaryDirectory().stringByAppendingPathComponent("os.ini")
        
        println("Writing temporary configuration file:\n\(configString)")
        
        // write to disc
        var error: NSError?
        configString.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        
        assert(error == nil, "Could not write temporary configuration file to disk. (\(error!.localizedDescription))")
        
        return path
    }
}
