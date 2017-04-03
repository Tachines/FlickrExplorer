//
//  PhotoItem.swift
//  FlickrExplorer
//
//  Created by Tachines on 24/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON

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
        let loadURL = (size == "h") ? imageURL(size: "h") : imageURL()
        Alamofire.request(loadURL).responseImage { response in
            switch response.result {
            case .success:
                if let image = response.result.value {
                    completion(image)
                }
            case .failure(let error):
                completion(nil)
                print(error)
            }
        }
    }
    
    func loadTag(completion: @escaping ([String]?) -> ()) {
        let imageTagUrl = "https://api.flickr.com/services/rest/?method=flickr.tags.getListPhoto&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1"
        Alamofire.request(imageTagUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let jsonTagListTemp = JSON(value)
                    let jsonTagList = jsonTagListTemp["photo"]["tags"]["tag"]
                    let totalNumber = jsonTagListTemp["photo"]["tags"]["tag"].count
                    var tags = [String]()
                    if totalNumber > 0 {
                        for i in 0 ..< totalNumber {
                            tags.append(jsonTagList[i]["raw"].stringValue.lowercased())
                        }
                        completion(tags)
                    } else {
                        completion(nil)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

