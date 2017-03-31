//
//  ImageDetailViewController.swift
//  FlickrExplorer
//
//  Created by Tachines on 25/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoName: UILabel!
    @IBOutlet weak var photoId: UILabel!
    @IBOutlet weak var photoSize: UILabel!
    @IBOutlet weak var photoTags: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    var photoItem: PhotoItem?
    
    override func viewDidLoad() {
        imageScrollView.minimumZoomScale = 1
        imageScrollView.maximumZoomScale = 3
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .gray
        setImageDetails()
    }
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func loadLargeImage(photoItem: PhotoItem) {
        photoItem.loadImage(size: "h") { completion in
            if completion != nil {
                

                    self.activityIndicatorView.stopAnimating()
                    self.imageView.image = completion
                    let actualWidth = completion!.size.width
                    let actualHeight = completion!.size.height
                    self.photoSize.text = "\(actualWidth)(W) x \(actualHeight)(H)"
    
            }
        }
    }
    
    fileprivate func setImageDetails() {
        
        if self.photoItem?.title == "" {
            self.titleLabel.text = "Untitled"
            self.photoName.text = "Untitled"
        } else {
            self.titleLabel.text = self.photoItem?.title
            self.photoName.text = self.photoItem?.title
        }
        self.photoId.text = self.photoItem?.photoID
        
        loadLargeImage(photoItem: photoItem!)
        activityIndicatorView.startAnimating()
        self.photoItem?.loadTag() { completion in
            
            if completion != nil {
                self.photoTags.text = completion!.joined(separator: " ")
            } else {
                self.photoTags.text = "No tag found"
            }
        
        }
        
    }
}
