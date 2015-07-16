//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    class func createInManagedObjectContext(context: NSManagedObjectContext, pin: Pin, photoUrlString: String) -> Photo {
        let newPhoto = NSEntityDescription.insertNewObjectForEntityForName(Constants.PhotoEntityName, inManagedObjectContext: context) as! Photo
        newPhoto.pin = pin
        newPhoto.photoUrlString = photoUrlString
        CoreDataStackManager.sharedInstance().saveContext()
        return newPhoto
    }
    
    var title: String {
        return photoUrlString
    }
    
}