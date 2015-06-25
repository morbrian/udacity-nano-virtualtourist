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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapManager()
        if let restoredRegion = mapManager.restoreRegion() {
            mapView.setRegion(restoredRegion, animated: true)
        }
        mapView.delegate = self
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        mapManager.saveRegion(mapView.region)
    }
    
}

