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
    
    var photos: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photos = photos {
            for p in photos {
                Logger.info("- \(p.photoUrlString)")
            }
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
            
            cell.photo = photo
            
            return cell
    }
}
