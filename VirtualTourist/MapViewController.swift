//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/22/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MapViewController
// Displays a map showing tourist locations geographically.
class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var context: NSManagedObjectContext!
    
    var userPreferences: UserPreferences!

    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataStackManager.sharedInstance().managedObjectContext!
        
        userPreferences = UserPreferences.sharedInstance()
        if let restoredRegion = userPreferences.restoreRegion() {
            mapView.setRegion(restoredRegion, animated: true)
        }

        var error: NSError? = nil
        
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
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
            var pin = Pin.createInManagedObjectContext(context!, location: coordinate)
            
            self.mapView.addAnnotation(pin)
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: Constants.PinEntityName)
        
        // Add a sort descriptor. This enforces a sort order on the results that are generated
        // In this case we want the events sored by their timeStamps.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()

}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    // save the displayed region on every pan or zoom
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        userPreferences.saveRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            let reuseId = Constants.PinAnnotationReuseIdentifier
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = false
                pinView!.draggable = false
                pinView!.animatesDrop = true
                pinView!.pinColor = .Green
            } else {
                pinView!.annotation = annotation
            }
            
            return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        self.performSegueWithIdentifier(Constants.ShowAlbumSegue, sender: view.annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? AlbumViewController,
            pin = sender as? Pin {
                destination.pin = pin
        }
    }
}

// MARK: - MKAnnotation

extension Pin: MKAnnotation {
    
    var title: String! {
        return ""
    }
    
    var subtitle: String! {
        return ""
    }
    
    var draggable: Bool {
        return false
    }
}

// MARK: - Printable MKAnnotationViewDragState

extension MKAnnotationViewDragState: Printable {
    public var description: String {
        switch self {
        case None: return "None"
        case Starting: return "Starting"
        case Dragging: return "Dragging"
        case Canceling: return "Canceling"
        case Ending: return "Ending"
        }
    }
}

