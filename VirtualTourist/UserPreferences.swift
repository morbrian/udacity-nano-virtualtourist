//
//  UserPreferences.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import MapKit


// UserPreferences
// Encapsulate any user settings or preferences specific to application or display.
class UserPreferences {
    
    // singleton instance
    class func sharedInstance() -> UserPreferences {
        struct Static {
            static let instance = UserPreferences()
        }
        return Static.instance
    }
    
    private init() {}
    
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

extension UserPreferences {
    struct MapStateKeys {
        static let Saved = "map.region.saved"
        static let SpanLatitude = "map.region.span.latitudeDelta"
        static let SpanLongitude = "map.region.span.longitudeDelta"
        static let CenterLatitude = "map.region.center.latitude"
        static let CenterLongitude = "map.region.center.longitude"
    }
}