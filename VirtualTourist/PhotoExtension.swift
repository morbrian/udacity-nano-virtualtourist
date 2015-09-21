//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/12/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Photo Extension
// Exposes additional capabilities on the Photo Model.
extension Photo {
    
    // creates a new Photo, associates it with the pin and photoUrl, and persist it.
    class func createInManagedObjectContext(context: NSManagedObjectContext, pin: Pin, photoUrlString: String) -> Photo {
        let newPhoto = NSEntityDescription.insertNewObjectForEntityForName(Constants.PhotoEntityName, inManagedObjectContext: context) as! Photo
        newPhoto.pin = pin
        newPhoto.photoUrlString = photoUrlString
        CoreDataStackManager.sharedInstance().saveContext()
        return newPhoto
    }
    
    var title: String? {
        return photoUrlString
    }
    
    var photoUrlString: String? {
        get {
            if let photoPath = photoPath where !photoPath.isEmpty {
                let parts = photoPath.pathComponents
                let firstSeparator = find(photoPath, "/")
                let host = photoPath[photoPath.startIndex..<firstSeparator!]
                let path = photoPath[firstSeparator!..<photoPath.endIndex]
                return "https://\(host)\(path)"
            } else {
                return nil
            }
        }
        
        set {
            if let newValue = newValue,
                newPathUrl =  NSURL(string: newValue) {
                photoPath = "\(newPathUrl.host!)\(newPathUrl.path!)"
            } else {
                photoPath = nil
            }
        }
    }
    
    var photoImage: UIImage? {
        
        get {
            return FlickrService.Caches.imageCache.imageWithIdentifier(photoPath)
        }
        
        set {
            if let photoPath = photoPath {
                FlickrService.Caches.imageCache.storeImage(newValue, withIdentifier: photoPath)
            }
        }
    }
    
    // MARK: - All purpose task method for images
    
    func taskForImage(completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: self.photoUrlString!)!
        let request = NSURLRequest(URL: url)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                //let newError = TheMovieDB.errorForData(data, response: response, error: downloadError)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(imageData: nil, error: error)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(imageData: data, error: nil)
                })
            }
        }
        
        task.resume()
        
        return task
    }
    
    // loads the image on a background thread, runs the completion handler back on the main thread
//    func loadImageTask(completionHandler: (image: UIImage?, error: NSError?) -> (Void)) -> NSURLSessionTask {
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, downloadError in
//            
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
//                if let imageUrlString = self.photoUrlString,
//                    imageUrl = NSURL(string: imageUrlString),
//                    imageData = NSData(contentsOfURL: imageUrl) {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        completionHandler(image: UIImage(data: imageData), error: nil)
//                    })
//                } else {
//                    Logger.error("No Image Data From URL: \(self.photoUrlString)")
//                    dispatch_async(dispatch_get_main_queue(), {
//                        // TODO: create error object
//                        completionHandler(image: nil, error: nil)
//                    })
//                }
//            }
//        }
//        task.resume()
//        return task
//    }
    
}
