//
//  PhotoCell.swift
//  FlickrExplorer
//
//  Created by Tachines on 24/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit
import NVActivityIndicatorView



class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    override func prepareForReuse() {
        photoImageView.image = nil
        super.prepareForReuse()
    }
    
    func downloadPhotoWithTags(photoItem: PhotoItem) {
        setIndicator()
        photoItem.loadImage(size: "n") { completion in
            if completion != nil {
                self.photoImageView.image = completion
            }
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    fileprivate func setIndicator() {
        activityIndicatorView.color = .gray
        activityIndicatorView.type = .ballClipRotate
        activityIndicatorView.startAnimating()
    }
}
