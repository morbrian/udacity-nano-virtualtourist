//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/6/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import Foundation
import UIKit


class AlbumViewController: UIViewController {
    
    let CollectionCellsPerRowLandscape = 5
    let CollectionCellsPerRowPortrait = 3
    
    // CODE: set as 2 in IB, not sure how to reference that value in code, so keep this in sync
    let CollectionCellSpacing = 2
    
    var photos: [Photo]?
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
        if let photos = photos {
            for p in photos {
                Logger.info("- \(p.photoUrlString)")
            }
        }
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

}

// MARK: - UICollectionViewDelegate

extension AlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: miniumum - offer option to delete; optional -  provide other capability like edit/annotate perhaps
    }
    
}

// MARK: - UICollectionViewDataSource

extension AlbumViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            var photo = photos?[indexPath.item]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.AlbumCellIdentifier, forIndexPath: indexPath) as! AlbumCellView
            
            // reset the image so we won't see the wrong image during loading when cell is reused
            cell.imageView?.image = nil
            cell.photo = photo
            
            return cell
    }
}
