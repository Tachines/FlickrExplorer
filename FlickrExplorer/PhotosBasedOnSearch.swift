//
//  imagesBasedOnSearch.swift
//  FlickrExplorer
//
//  Created by Tachines on 26/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import Foundation

class PhotosBasedOnSearch {
    
    fileprivate var photoList = PhotoList()
    
    func loadPhotoList(searchTerm: String, followUpOnTags: Bool, completion: @escaping ([PhotoItem]?) -> ()) {
        let photoListAddress: String
        if !followUpOnTags {
            photoListAddress = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(searchTerm)&per_page=500&format=json&nojsoncallback=1"
        } else {
            photoListAddress = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&tags=\(searchTerm)&format=json&nojsoncallback=1"
        }
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let photoListUrl = URL(string: photoListAddress)!
        let task = session.dataTask(with: photoListUrl, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        if let jsonPhotoListTemp = json["photos"] as? [String: Any] {
                            if let jsonPhotoList = jsonPhotoListTemp["photo"] as? [[String: Any]] {
                                if jsonPhotoList.count == 0 {
                                    completion(nil)
                                } else {
                                    // prepare to load photo
                                    let returnPhotos = self.photoList.addPhotoToList(jsonPhotoList: jsonPhotoList)
                                    completion(returnPhotos)
                                }
                            }
                        }
                    }
                } catch {
                    print("Response doesn't conform to json format")
                }
            }
        })
        task.resume()
    }
    
    
    
}
