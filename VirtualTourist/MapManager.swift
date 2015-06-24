//
//  MapManager.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 6/22/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation

class MapManager {
    
    var mapState: MapState?
    
    init() {
        mapState = NSKeyedUnarchiver.unarchiveObjectWithFile(mapStateFilePath) as? MapState
        if mapState == nil {
            mapState = MapState()
        }
        Logger.info("MapState is: \(mapState)")
    }
    
    func saveState() {
        if let mapState = mapState {
            NSKeyedArchiver.archiveRootObject(mapState, toFile: mapStateFilePath)
        }
        Logger.info("Saved MapState: \(mapState)")
    }
    
    var mapStateFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapState").path!
    }
}