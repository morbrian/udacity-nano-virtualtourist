//
//  Pin.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/26/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber

}
