//
//  Pin.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)

class Pin: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]

}
