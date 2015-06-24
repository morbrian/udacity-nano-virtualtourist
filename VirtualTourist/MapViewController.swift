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
    
    var mapManager: MapManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapManager = MapManager()
        if let mapState = mapManager?.mapState,
            mapRegion = mapState.mapRegion {
                mapView.setRegion(mapRegion, animated: true)
        } else {
            mapManager?.mapState?.mapRegion = mapView.region
        }

        mapView.delegate = self
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        Logger.info("RegionDidChange")
        mapManager?.mapState?.mapRegion = mapView.region
        mapManager?.saveState()
        
    }
    
}

