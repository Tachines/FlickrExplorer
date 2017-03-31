//
//  PhotoCell.swift
//  FlickrExplorer
//
//  Created by Tachines on 24/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }
    
    func downloadPhotoforCell(photoItem: PhotoItem) {
        activityIndicatorView.startAnimating()
        photoItem.loadImage(size: "n") { completion in
            if completion != nil {
                self.photoImageView.image = completion
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
}
