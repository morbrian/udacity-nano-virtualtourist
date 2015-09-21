//
//  Photo.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {

    @NSManaged var photoPath: String?
    @NSManaged var pin: Pin?

}
