//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/22/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var mapManager: MapManager!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapManager()
        if let restoredRegion = mapManager.restoreRegion() {
            mapView.setRegion(restoredRegion, animated: true)
        }
        
        if let managedObjectContext = managedObjectContext {
            var pins = mapManager.fetchTravelLocationsFromContext(managedObjectContext)
            mapView.addAnnotations(pins)
        }
        
        mapView.delegate = self
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "handleLongPress:"))
    }
    
    // MARK: Gestures
    
    // When press and hold on the map the view, add a new pin.
    func handleLongPress(sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            var coordinate = mapView.convertPoint(sender.locationOfTouch(0, inView: mapView), toCoordinateFromView: mapView)
            var pin = mapManager.createTravelLocation(coordinate, inManagedObjectContext: self.managedObjectContext!)
            self.mapView.addAnnotation(pin)
        }
    }
    

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        mapManager.saveRegion(mapView.region)
    }
    
}

extension Pin: MKAnnotation {
    
    @objc var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
    var title: String! {
        return ""
    }
    
    var subtitle: String! {
        return ""
    }
}





