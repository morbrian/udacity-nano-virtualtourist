//
//  TaskCancelingCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Brian Moriarty on 9/19/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//
//  Reference: mostly copied from Udacity code.
//

import UIKit

class TaskCancelingCollectionViewCell : UICollectionViewCell {
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    
    var imageName: String = ""
    @IBOutlet weak var imageView: UIImageView?
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
