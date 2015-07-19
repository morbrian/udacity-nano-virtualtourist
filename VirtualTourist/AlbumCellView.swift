//
//  AlbumCellView.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

class AlbumCellView: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView? {
        didSet {
            // TODO: this is not showing the desired effect, may need to embed in containing view.
            activityIndicator?.layer.cornerRadius = 8.0
            activityIndicator?.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                activityIndicator?.startAnimating()
                photo.loadImage() { image, error in
                    // since this cell is reused, make sure when the thread
                    // comes back onto main the cell still has the same photo.
                    if self.photo?.photoUrlString == photo.photoUrlString {
                        self.activityIndicator?.stopAnimating()
                        self.imageView?.image = image
                    }
                }
            }
        }
    }
    
    
    
}
