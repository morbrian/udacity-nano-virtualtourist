//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

// Pin Extension
// Exposes additional capability on the Pin model.
extension Pin {
    
    class func createInManagedObjectContext(context: NSManagedObjectContext, location: CLLocationCoordinate2D) -> Pin {
        let newPin = NSEntityDescription.insertNewObjectForEntityForName(Constants.PinEntityName, inManagedObjectContext: context) as! Pin
        newPin.coordinate = location
        CoreDataStackManager.sharedInstance().saveContext()
        newPin.refreshPhotos()
        return newPin
    }
    
    class func fetchFromManagedObjectContext(context: NSManagedObjectContext) -> [Pin] {
        // Create a new fetch request using the Pin entity
        let fetchRequest = NSFetchRequest(entityName: Constants.PinEntityName)
        
        // Execute the fetch request, and cast the results to an array of Pin objects
        if let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [Pin] {
            return fetchResults
        } else {
            Logger.error("Failed to find proper Pin array")
            return [Pin]()
        }
    }
    
    func refreshPhotos() {
        for photo in photos {
            photo.pin = nil
        }
        FlickrService.sharedInstance().fetchPhotosNearCoordinates(latitude: Double(latitude), longitude: Double(longitude)) { photoUrls, error in
            if let error = error {
                Logger.error("Failed to get photo list for pin: \(error)")
            } else if let photoUrls = photoUrls {
                for photoUrl in photoUrls {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let context = self.managedObjectContext {
                            Photo.createInManagedObjectContext(context, pin: self, photoUrlString: photoUrl.absoluteString!)
                        }
                    }
                }
            }
        }

    }
    
}

// MARK: - Pin Model Extenstions

extension Pin {

    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
            refreshPhotos()
        }
    }
    
}