//
//  ViewController.swift
//  FlickrExplorer
//
//  Created by Tachines on 23/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

let apiKey = "856e9424143b4897159666a5cd4439b0"
// get location and render
class ViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var photoList = PhotoList()
    fileprivate var photos = [PhotoItem]()
    fileprivate var locationLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        self.locationManager.startUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotosSegue" {
            if let navigationViewController = segue.destination as? UINavigationController {
                let destinationViewController = navigationViewController.topViewController as! ImageCollectionViewController
                destinationViewController.photos = photos
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locationLoaded {
            let userLocation: CLLocation = locations[0]
            let longitude = userLocation.coordinate.longitude
            let latitude = userLocation.coordinate.latitude
            loadPhotoList(longitude: longitude, latitude: latitude, hasLocation: true)
            locationLoaded = true
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        reloadList(title: "Cannot access your location")
    }
}
// load photo list
extension ViewController {
    fileprivate func loadPhotoList(longitude: Double, latitude: Double, hasLocation: Bool) {
        let photoListUrl: String
        if hasLocation {
            photoListUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&per_page=250&format=json&nojsoncallback=1"
        } else {
            photoListUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&per_page=250&format=json&nojsoncallback=1"
        }

        Alamofire.request(photoListUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let jsonPhotoListTemp = JSON(value)
                    let jsonPhotoList = jsonPhotoListTemp["photos"]["photo"]
                    let totalNumber = jsonPhotoListTemp["photos"]["total"].intValue
                    if totalNumber == 0 {
                        // load photo without geolocation attributes
                        self.reloadList(title: "No Photo Found at Your Locaiton")
                    } else {
                        // prepare to load photo
                        self.photos = self.photoList.addPhotoToList(jsonPhotoList: jsonPhotoList)
                        self.activityIndicatorView.stopAnimating()
                        self.performSegue(withIdentifier: "showPhotosSegue", sender: nil)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func reloadList(title: String) {
        let alert = UIAlertController(title: title, message: "Will show the latest photos uploaded to Flickr", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.loadPhotoList(longitude: 0, latitude: 0, hasLocation: false)
        }))
        self.present(alert, animated:true, completion:nil)
    }
}
