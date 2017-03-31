//
//  PhotoItem.swift
//  FlickrExplorer
//
//  Created by Tachines on 24/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import Foundation
import UIKit

class PhotoItem {
    
    let photoID: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
    var photoTags: [String]?
    
    init(photoID: String, farm: Int, server: String, secret: String, title: String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    fileprivate func imageURL(size: String = "n") -> String {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg"
        return url
    }
    
    func loadImage(size: String, completion: @escaping (UIImage?) -> ()) {
        let imageAddress = (size == "h") ? imageURL(size: "h") : imageURL()
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let photoListUrl = URL(string: imageAddress)!
        
        let task = session.dataTask(with: photoListUrl, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil)
            } else {
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    // get image successfully
                    
                    completion(image)
                    
                } else {
                    print("Fail to download image")
                    completion(nil)
                }
            }
        })
        task.resume()
    }
    
    func loadTag(completion: @escaping ([String]?) -> ()) {
        let imageTagAddress = "https://api.flickr.com/services/rest/?method=flickr.tags.getListPhoto&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1"
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let photoListUrl = URL(string: imageTagAddress)!
        
        let task = session.dataTask(with: photoListUrl, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        if let jsonTagListTemp = json["photo"] as? [String: Any] {
                            if let jsonAllTagsList = jsonTagListTemp["tags"] as? [String: Any] {
                                if let jsonTagList = jsonAllTagsList["tag"] as? [[String: Any]] {
                                    var tags = [String]()
                                    if jsonTagList.count > 0 {
                                        for i in 0 ..< jsonTagList.count {
                                            let tempString = jsonTagList[i]["raw"] as! String
                                            tags.append(tempString.lowercased())
                                        }
                                        completion(tags)
                                    } else {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("Response doesn't conform to json format")
                    completion(nil)
                }
            }
        })
        task.resume()
    }
}
