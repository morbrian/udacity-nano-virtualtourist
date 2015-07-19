//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Photo Extension
// Exposes additional capabilities on the Photo Model.
extension Photo {
    
    // creates a new Photo, associates it with the pin and photoUrl, and persist it.
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

    // loads the image on a background thread, runs the completion handler back on the main thread
    func loadImage(completionHandler: (image: UIImage?, error: NSError?) -> (Void)) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            let imageURL = NSURL(string: self.photoUrlString)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(image: UIImage(data: imageData), error: nil)
                })
            } else {
                Logger.error("No Image Data From URL: \(imageURL)")
                dispatch_async(dispatch_get_main_queue(), {
                    // TODO: create error object
                    completionHandler(image: nil, error: nil)
                })
            }
        }
    }
    
}
