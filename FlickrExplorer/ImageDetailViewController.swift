//
//  ImageDetailViewController.swift
//  FlickrExplorer
//
//  Created by Tachines on 25/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoName: UILabel!
    @IBOutlet weak var photoId: UILabel!
    @IBOutlet weak var photoSize: UILabel!
    @IBOutlet weak var photoTags: UILabel!
    
    var photoItem: PhotoItem?
    
    override func viewDidLoad() {
        imageScrollView.minimumZoomScale = 1
        imageScrollView.maximumZoomScale = 3
        setIndicator()
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
                let actualWidth = UIScreen.main.scale * completion!.size.width
                let actualHeight = UIScreen.main.scale * completion!.size.height
                self.photoSize.text = "\(actualWidth)(W) x \(actualHeight)(H)"
            }
        }
    }
    
    fileprivate func setImageDetails() {
        if photoItem?.title == "" {
            titleLabel.text = "Untitled"
            photoName.text = "Untitled"
        } else {
            titleLabel.text = photoItem?.title
            photoName.text = photoItem?.title
        }
        photoId.text = photoItem?.photoID
        
        loadLargeImage(photoItem: photoItem!)
        activityIndicatorView.startAnimating()
        photoItem?.loadTag() { completion in
            if completion != nil {
                self.photoTags.text = completion!.joined(separator: " ")
            } else {
                self.photoTags.text = "No tag found"
            }
        }
    }
    
    fileprivate func setIndicator() {
        activityIndicatorView.color = .gray
        activityIndicatorView.type = .ballClipRotate
        activityIndicatorView.startAnimating()
    }
}
