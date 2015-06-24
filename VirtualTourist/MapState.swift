//
//  MapState.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/22/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import MapKit

class MapState: NSObject, NSCoding, Printable {
    
    struct Keys {
        static let LatitudeSpan = "latitudeSpan"
        static let LongitudeSpan = "longitudeSpan"
        static let LatitudeCenter = "latitudeCenter"
        static let LongitudeCenter = "longitudeCenter"
    }

    var mapRegion: MKCoordinateRegion?
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        if let latitudeSpan = aDecoder.decodeObjectForKey(Keys.LatitudeSpan) as? CLLocationDegrees,
            longitudeSpan = aDecoder.decodeObjectForKey(Keys.LongitudeSpan) as? CLLocationDegrees,
            latitudeCenter = aDecoder.decodeObjectForKey(Keys.LatitudeCenter) as? CLLocationDegrees,
            longitudeCenter = aDecoder.decodeObjectForKey(Keys.LongitudeCenter) as? CLLocationDegrees {
            
                let center = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeCenter)
                let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
                mapRegion = MKCoordinateRegionMake(center, span)
        }
    }

    init(dictionary: [String : AnyObject]) {
        if let latitudeSpan = dictionary[Keys.LatitudeSpan] as? CLLocationDegrees,
            longitudeSpan = dictionary[Keys.LongitudeSpan] as? CLLocationDegrees,
            latitudeCenter = dictionary[Keys.LatitudeCenter] as? CLLocationDegrees,
            longitudeCenter = dictionary[Keys.LongitudeCenter] as? CLLocationDegrees {
                
                let center = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeCenter)
                let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
                mapRegion = MKCoordinateRegionMake(center, span)
        }
    }

    func encodeWithCoder(archiver: NSCoder) {
        if let mapRegion = mapRegion {
            archiver.encodeObject(mapRegion.span.latitudeDelta, forKey: Keys.LatitudeSpan)
            archiver.encodeObject(mapRegion.span.longitudeDelta, forKey: Keys.LongitudeSpan)
            archiver.encodeObject(mapRegion.center.latitude, forKey: Keys.LatitudeCenter)
            archiver.encodeObject(mapRegion.center.longitude, forKey: Keys.LongitudeCenter)
        }
    }
    
    override var description: String {
        var dataString =
        "{ \"mapState\" : { " +
        "\"\(Keys.LatitudeSpan)\":\"\(mapRegion?.span.latitudeDelta)\"," +
        "\"\(Keys.LongitudeSpan)\":\"\(mapRegion?.span.longitudeDelta)\"," +
        "}"
        
        return dataString
    }

}

