//
//  MapManager.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/22/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapManager {
    
    var travelLocations = [Pin]()
    
    init() { }
    
    func createTravelLocation(travelLocation: CLLocationCoordinate2D, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Pin {
        let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: managedObjectContext) as! Pin
        newLocation.latitude = travelLocation.latitude
        newLocation.longitude = travelLocation.longitude
        return newLocation
    }
    
    func fetchTravelLocationsFromContext(managedObjectContext: NSManagedObjectContext) -> [Pin] {
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Pin] {
            return fetchResults
        } else {
            Logger.error("Failed to find proper Pin array")
            return [Pin]()
        }

    }
    
    func saveRegion(mapRegion: MKCoordinateRegion) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(mapRegion.center.latitude, forKey: MapStateKeys.CenterLatitude)
        defaults.setDouble(mapRegion.center.longitude, forKey: MapStateKeys.CenterLongitude)
        defaults.setDouble(mapRegion.span.latitudeDelta, forKey: MapStateKeys.SpanLatitude)
        defaults.setDouble(mapRegion.span.longitudeDelta, forKey: MapStateKeys.SpanLongitude)
        defaults.setBool(true, forKey: MapStateKeys.Saved)
    }
    
    func restoreRegion() -> MKCoordinateRegion? {
        var defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey(MapStateKeys.Saved) {
            let center = CLLocationCoordinate2D(
                    latitude: defaults.doubleForKey(MapStateKeys.CenterLatitude),
                    longitude: defaults.doubleForKey(MapStateKeys.CenterLongitude))
            let span = MKCoordinateSpan(
                    latitudeDelta: defaults.doubleForKey(MapStateKeys.SpanLatitude),
                    longitudeDelta: defaults.doubleForKey(MapStateKeys.SpanLongitude))
            return MKCoordinateRegionMake(center, span)
        } else {
            return nil
        }
    }
}

// MARK: - Constants

extension MapManager {
    struct MapStateKeys {
        static let Saved = "map.region.saved"
        static let SpanLatitude = "map.region.span.latitudeDelta"
        static let SpanLongitude = "map.region.span.longitudeDelta"
        static let CenterLatitude = "map.region.center.latitude"
        static let CenterLongitude = "map.region.center.longitude"
    }
}