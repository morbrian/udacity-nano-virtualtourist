//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/6/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit
import CoreData

class AlbumViewController: UIViewController {
    
    let CollectionCellsPerRowLandscape = 5
    let CollectionCellsPerRowPortrait = 3
    
    // CODE: set as 2 in IB, not sure how to reference that value in code, so keep this in sync
    let CollectionCellSpacing = 2
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    var pin: Pin?
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var defaultCount: Int?
    private var collectionCellCountPerRow: Int {
        let orientation = UIDevice.currentDevice().orientation
        switch orientation {
        case .LandscapeLeft, .LandscapeRight:
            defaultCount = CollectionCellsPerRowLandscape
            return CollectionCellsPerRowLandscape
        case .Portrait:
            defaultCount = CollectionCellsPerRowPortrait
            return CollectionCellsPerRowPortrait
        default:
            return defaultCount ?? CollectionCellsPerRowPortrait
        }
    }
    
    // MARK: ViewController Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        calculateCollectionCellSize()
    }
    
    // calculates cell size based on cells-per-row for the current device orientation
    private func calculateCollectionCellSize() {
        if let collectionView = collectionView {
            let width = collectionView.frame.width / CGFloat(collectionCellCountPerRow) - CGFloat(CollectionCellSpacing)
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.itemSize = CGSize(width: width, height: width)
        }
    }
    
    @IBAction func newCollectionAction(sender: UIBarButtonItem) {
        sharedContext.performBlockAndWait {
            for obj in self.fetchedResultsController.fetchedObjects! {
                let photo = obj as! Photo
                self.sharedContext.deleteObject(photo)
                FlickrService.Caches.imageCache.storeImage(nil, withIdentifier: photo.photoPath!)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
        pin?.fetchPhotoList() {fetchedResultsController.performFetch(nil)}
    }

    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoPath", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()

}

// MARK: - UICollectionViewDelegate

extension AlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        FlickrService.Caches.imageCache.storeImage(nil, withIdentifier: photo.copyPhotoPath!)
        sharedContext.performBlockAndWait {
            self.sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }

}

// MARK: - UICollectionViewDataSource

extension AlbumViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            // Here is how to replace the actors array using objectAtIndexPath
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.AlbumCellIdentifier, forIndexPath: indexPath) as! AlbumCellView
            
            // reset the image so we won't see the wrong image during loading when cell is reused
            cell.imageView?.image = nil
            cell.photo = photo
            
            return cell
    }
}

// MARK: - Fetched Results Controller Delegate

extension AlbumViewController:NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.collectionView.insertSections(NSIndexSet(index: sectionIndex))
                
            case .Delete:
                self.collectionView.deleteSections(NSIndexSet(index: sectionIndex))
                
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                
            case .Delete:
                collectionView.deleteItemsAtIndexPaths([indexPath!])
                
            case .Update:
                let cell = collectionView.cellForItemAtIndexPath(indexPath!) as! AlbumCellView
                let photo = controller.objectAtIndexPath(indexPath!) as! Photo
                //self.configureCell(cell, photo: photo)
                
            case .Move:
                collectionView.deleteItemsAtIndexPaths([indexPath!])
                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                
            default:
                return
            }
    }
    
}
