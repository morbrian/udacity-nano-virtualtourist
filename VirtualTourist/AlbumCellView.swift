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
    @IBOutlet weak var title: UILabel!
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
//                imageView?.image =  TODO: photo.loadImage()
                title?.text = photo.title
            }
        }
    }
    
}
