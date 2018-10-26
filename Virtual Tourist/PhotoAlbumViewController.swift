//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 04/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin: Pin!
    var dataController:DataController!
    var photosList:[Photo] = []
    private let kRegion:CLLocationDistance = 500000
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    fileprivate func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reLoadImagesFromFlickr))
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        annotation.coordinate = coordinate
        self.mapView .addAnnotation(annotation)
        let latitude:CLLocationDegrees =  annotation.coordinate.latitude
        let longitude:CLLocationDegrees = annotation.coordinate.longitude
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: kRegion, longitudinalMeters: kRegion)
        mapView.setRegion(region, animated: true)
        setupFetchedResultsController()
    }
    
    @objc fileprivate func reLoadImagesFromFlickr() {

        self.selectedPin.removeFromPhotos(self.selectedPin.photos!)
        
        try? dataController.viewContext.save()
        

        self.photosList.removeAll()
        collectionView.reloadData()
        

//        
//
//        let photo = photosList[indexPath.item]
//        
//        dataController.viewContext.delete(photo)
//        photosList.remove(at: indexPath.item)
//        try? self.dataController.viewContext.save()
//        collectionView.deleteItems(at: [indexPath])
//        
//        
        
        
        //self.selectedPin.photos = NSSet(array: [])
        
        self.loadImagesFromFlickr()
    }
    
    fileprivate func loadImagesFromFlickr() {
       
            let service = VirtualTouristService.sharedInstance()
            let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
            service.getPhotosFromFlickr(coordinate, completion: { (success, message, photos) in
                if success {
                    if let photos = photos {
                        
                        for photo in photos {
                            let newPhoto = Photo(context: self.dataController.viewContext)
                            newPhoto.url_m = photo["url_m"] as? String
                            newPhoto.pin = self.selectedPin
                            //self.selectedPin.addToPhotos(newPhoto)
                            // self.photosList.insert(new, at: <#T##Int#>)
                            // self.selectedPin.addToPhotos(newPhoto)
                            // self.photosList.append(newPhoto)
                            //  self.photosList.insert(newPhoto, at: self.photosList.count)
                            
                            //  try? self.dataController.viewContext.save()
                            //self.photosList.insert(newPhoto, at: 0)
                            //                            self.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                            try? self.dataController.viewContext.save()
                        }
                        
                        if let arrayPhotos = self.selectedPin.photos?.allObjects as? [Photo] {
                            self.photosList = arrayPhotos
                            //self.photosList.insert(contentsOf: arrayPhotos, at: 0)
                            //                            for photo in arrayPhotos {
                            //                                self.photosList.insert(photo, at: 0)
                            //                            }
                        }
                        //self.selectedPin.addToPhotos(NSSet(array: self.photosList))
                        //  self.photosList = self.selectedPin.photos?.allObjects as? [Photo] ?? []
                        
                    }
                    //                    DispatchQueue.main.async(execute: { () -> Void in
                    //                        self.collectionView.reloadData()
                    //                    })
                    //
                } else {
                    if let message = message {
                        self.showMessageAlert(message)
                    }
                }
            });
        
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "url_m", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.selectedPin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil
        )
        fetchedResultsController.delegate = self
        do {
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                photosList = result
            }
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError(error.localizedDescription)
        }
        if selectedPin.photos?.count == 0 {
            loadImagesFromFlickr()
        }
        
        
        
    }
    
    func showMessageAlert(_ message:String) {
        let alert = UIAlertController(title: "Virtual Tourist", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(){
        try? self.dataController.viewContext.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       // print("controllerWillChangeContent")
        
        enableUI(enabled: false)
    }

//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type:
//        NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: collectionView.insertSections(indexSet, with: .fade)
//        case .delete: collectionView.deleteSections(indexSet, with: .fade)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
//
//
//        print("didChange")
//
//        collectionView.reloadData()
//        enableUI(enabled: true)
//    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            collectionView.insertItems(at: [newIndexPath!])
            
        } else if type == .delete {
           // collectionView.deleteItems(at: [indexPath!])
        } else {
            collectionView.reloadItems(at: [indexPath!])
        }
//        switch type {
//        case .insert:
//            print("\(newIndexPath?.section) ------- \(newIndexPath?.row)")
//            break
//        case .delete:
//            collectionView.deleteItems(at: [indexPath!])
//            break
//       // case .update:
//      //      collectionView.reloadItems(at: [indexPath!])
//        case .move:
//            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
//        }
         enableUI(enabled: true)
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: collectionView.insertSections(indexSet)
//        case .delete: collectionView.deleteSections(indexSet)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
//        enableUI(enabled: true)
//    }
    
    func enableUI(enabled: Bool) {
        self.collectionView.isUserInteractionEnabled = enabled
        navigationItem.rightBarButtonItem?.isEnabled = enabled
        
    }

}



// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let s = self.fetchedResultsController?.sections {
            return s[section].numberOfObjects
        }
        return 0
    }

   
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImage.image = nil
        cell.downloadActivity.startAnimating()
        let photo = fetchedResultsController.object(at: indexPath)
        print("indexx -> \(indexPath.section) \(indexPath.row)")
        //let photo = photosList[indexPath.row]
        
        
        if photo.binaryPhoto != nil {
            cell.downloadActivity.stopAnimating()
            cell.photo = photo
            
        } else {
            //print("Downloading - > \(indexPath.section)  \(indexPath.row)  - \(photo.url_m!)")
            URLSession.shared.dataTask(with: NSURL(string: photo.url_m!)! as URL, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error ?? "error")
                    return
                }
                photo.binaryPhoto = data
                
            }).resume()
        }
        
        cell.backgroundColor = UIColor.green
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //photos.remove(at: indexPath.row)
        
        let photo = photosList[indexPath.item]
        
        dataController.viewContext.delete(photo)
        photosList.remove(at: indexPath.item)
        try? self.dataController.viewContext.save()
        collectionView.deleteItems(at: [indexPath])
       // collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems!)
//
//        self.collectionView.performBatchUpdates({
//            let photo = photosList[indexPath.row]
//            dataController.viewContext.delete(photo)
//            //selectedPin.removeFromPhotos(photosList[indexPath.row])
//
//            try? self.dataController.viewContext.save()
//            photosList.remove(at: indexPath.row)
//            collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems!)
//        }) { (finished) in
//        }
        
        
        
        
        //collectionView.deleteItems(at: [indexPath])
        
        
        //try? selectedPin.managedObjectContext?.save()
//        collectionView.deleteItems(at: [indexPath] )
        
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fetchedResultsController = fetchedResultsController {
            return fetchedResultsController.sections?.count ?? 1
        }
        return 0
    }
}
