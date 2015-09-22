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
        var pin: Pin?
        context.performBlockAndWait {
            let newPin = NSEntityDescription.insertNewObjectForEntityForName(Constants.PinEntityName, inManagedObjectContext: context) as! Pin
            newPin.coordinate = location
            CoreDataStackManager.sharedInstance().saveContext()
            pin = newPin
        }
        return pin!
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
    
    func fetchPhotoList(completionHandler: (() -> Void)? = nil) {
        FlickrService.sharedInstance().fetchPhotosNearCoordinates(latitude: Double(copyLatitude), longitude: Double(copyLongitude)) { photoUrls, error in
            if let error = error {
                Logger.error("Failed to get photo list for pin: \(error)")
            } else if let photoUrls = photoUrls {
                for photoUrl in photoUrls {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let context = self.managedObjectContext {
                            Photo.createInManagedObjectContext(context, pin: self, photoUrlString: photoUrl.absoluteString!)
                              completionHandler?()
                        }
                    }
                }
            }
        }

    }
    
}

// MARK: - Pin Model Extenstions

extension Pin {
    
    var copyLatitude: Double {
        var copy: Double?
        self.managedObjectContext?.performBlockAndWait {
            copy = self.latitude
        }
        return copy!
    }
    
    var copyLongitude: Double {
        var copy: Double?
        self.managedObjectContext?.performBlockAndWait {
            copy = self.longitude
        }
        return copy!
    }

    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.copyLatitude), longitude: CLLocationDegrees(self.copyLongitude))
        }
        set {
            Logger.info("SETTING COORD ON PIN")
            self.managedObjectContext?.performBlockAndWait {
                self.latitude = newValue.latitude
                self.longitude = newValue.longitude
            }
            Logger.info("COMPLETE COORD SET, START FETCH")
            fetchPhotoList()
            Logger.info("FETCH COMPLETED")
        }
    }
    
}