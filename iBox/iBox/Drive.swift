//
//  Drive.swift
//  iBox
//
//  Created by Alsey Coleman Miller on 11/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

class Drive: NSManagedObject {

    @NSManaged var fileName: String
    @NSManaged var ataInterfaceMaster: ATAInterface
    @NSManaged var ataInterfaceSlave: ATAInterface

}
