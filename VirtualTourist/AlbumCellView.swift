//
//  AlbumCellView.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 7/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

class AlbumCellView: TaskCancelingCollectionViewCell {
    
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
                configureCell(photo)
            }
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(photo: Photo) {
        // Set the Image

        if photo.photoPath == nil || photo.photoPath!.isEmpty {
            imageView!.image = UIImage(named: "photoNoImage")
        } else if photo.photoImage != nil {
            imageView!.image = photo.photoImage
        }
            
        else { // This is the interesting case. The movie has an image name, but it is not downloaded yet.
            
            imageView!.image =  UIImage(named: "photoPlaceHoldr")
            
            // Start the task that will eventually download the image
            let task = photo.taskForImage() { data, error in
                
                if let error = error {
                    println("Poster download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    // Craete the image
                    let image = UIImage(data: data)
                    
                    // update the model, so that the infrmation gets cashed
                    photo.photoImage = image
                    
                    if self.photo?.photoPath == photo.photoPath {
                        self.activityIndicator?.stopAnimating()
                        self.imageView!.image = image
                    }
                }
            }
            task.resume()
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            taskToCancelifCellIsReused = task
        }
    }
    
}
