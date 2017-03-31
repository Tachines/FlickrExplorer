//
//  ImageCollectionViewController.swift
//  FlickrExplorer
//
//  Created by Tachines on 23/3/17.
//  Copyright © 2017 Tac. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let cellEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate var photoItem: PhotoItem?
    fileprivate let searchBar = UISearchBar()
    fileprivate var photosBasedOnSearch = PhotosBasedOnSearch()
    // Determine whether to start a filter or search
    fileprivate var isSearch = true
    // back-up photos' information so that user can reset filter
    fileprivate var oldPhotos = [PhotoItem]()
    fileprivate var itemCount = 0
    
    var photos = [PhotoItem]()
    
    override func viewDidLoad() {
        searchBar.sizeToFit()
        itemCount = photos.count
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        resetButton.isEnabled = false
        searchBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetailSegue" {
            if let destinationViewController =  segue.destination as? ImageDetailViewController {
                destinationViewController.photoItem = photoItem
            }
        }
    }
    // reset filter or previous search, this will always start a new search
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        if oldPhotos.count > 0 {
            photos = oldPhotos
        }
        itemCount = photos.count
        collectionView.reloadData()
        isSearch = true
        searchBar.placeholder = "Search"
        searchBar.text = nil
        resetButton.isEnabled = false
    }
}

extension ImageCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.downloadPhotoforCell(photoItem: photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        photoItem = photos[indexPath.row]
        self.performSegue(withIdentifier: "showImageDetailSegue", sender: nil)
    }
}

extension ImageCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = cellEdgeInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return cellEdgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellEdgeInsets.left
    }
}

extension ImageCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if isSearch {
            photosBasedOnSearch.loadPhotoList(searchTerm: searchBar.text!) { completion in
                if completion != nil {
                    // replace object array photos with search result
                    self.photos = completion!
                    self.itemCount = self.photos.count
                    self.isSearch = false
                    self.resetButton.isEnabled = true
                    self.oldPhotos.removeAll()
                    self.searchBar.placeholder = "Filter on tags or reset to start a new search"
                    self.searchBar.text = nil
                    self.collectionView.reloadData()
                } else {
                    let alert = UIAlertController(title: "No Result Found", message: "Please change your search term", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let searchText = searchBar.text?.lowercased()
            let myGroup = DispatchGroup()
            var indexPathForDeleteArray = [IndexPath]()
            for i in 0 ..< self.photos.count {
                myGroup.enter()
                self.photos[i].loadTag() { completion in
                    self.photos[i].photoTags = completion
                    if completion != nil {
                        if !completion!.contains(searchText!) {
                            let indexPath = IndexPath(item: i, section: 0)
                            indexPathForDeleteArray.append(indexPath)
                        }
                    } else {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPathForDeleteArray.append(indexPath)
                    }
                    myGroup.leave()
                }
            }

            myGroup.notify(queue: .main) {
                self.oldPhotos = self.photos
                // https://openradar.appspot.com/28167779 issue for performBatchUpdates
                // so get indexPathForDeleteArray first and delete at once as a walkaround
                self.collectionView.performBatchUpdates({
                    self.itemCount -= indexPathForDeleteArray.count
                    self.collectionView.deleteItems(at: indexPathForDeleteArray)
                }, completion: nil)
                self.resetButton.isEnabled = true
            }
        }
    }
}

