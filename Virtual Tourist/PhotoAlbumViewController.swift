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
    
    private let kRegion:CLLocationDistance = 500000
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveViewContext()
    }
    
    fileprivate func setup() {
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects?.count == 0 {        
            loadImagesFromFlickr()
        }
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPhotoAlbumViewController))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadImageRandom))
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        annotation.coordinate = coordinate
        self.mapView .addAnnotation(annotation)
        let latitude:CLLocationDegrees =  annotation.coordinate.latitude
        let longitude:CLLocationDegrees = annotation.coordinate.longitude
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: kRegion, longitudinalMeters: kRegion)
        mapView.setRegion(region, animated: true)
        
    }
    
    func showMessage(_ message:String) {
        let alert = UIAlertController(title: "Virtual Tourist", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissPhotoAlbumViewController(){
        try? self.dataController.viewContext.save()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        
        cell.updateCellWithPhoto(photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        if photo.binaryPhoto == nil {
            return
        }
        dataController.viewContext.delete(photo)
        try? self.dataController.viewContext.save()
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate {
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.selectedPin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        collectionView.performBatchUpdates({
            collectionView.isUserInteractionEnabled = false
            switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .update:
                print("update")
                collectionView.reloadItems(at: [indexPath!])
            case .delete:
                collectionView.deleteItems(at: [indexPath!])
            default:
                print("default")
                break
            }
//        print("type \(type)")
        }) { (success) in
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.reloadData()
        }
        
    }
    
}

extension PhotoAlbumViewController {
    
    func downloadImages() {
        
        if let photos = self.fetchedResultsController!.fetchedObjects {
            
            let service = VirtualTouristService.sharedInstance()
            for photo in photos {
                service.downloadImageFromPhoto(photo)
            }
        }
    }
    
    @objc fileprivate func reloadImageRandom() {
        if let photos = fetchedResultsController!.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("eeeeerrrroooooo")
                }
            }
        }
        loadImagesFromFlickr()
    }
    
    
    
    fileprivate func loadImagesFromFlickr() {
        let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        
        let service = VirtualTouristService.sharedInstance()
        service.loadPhotosFromCoordinate(coordinate) { (success, message, photoArray) in
            if success {
                if let photoArray = photoArray {
                    self.createPinPhotosFromArray(photoArray)
                }
            } else {
                if let message = message {
                    self.showMessage(message)
                }
            }
        };
    }
    
    fileprivate func createPinPhotosFromArray(_ photoArray: [[String : AnyObject]]) {
        for photo in photoArray {
            let newPhoto = Photo(context: self.dataController.viewContext)
            newPhoto.url_m = photo["url_m"] as? String
            newPhoto.pin = self.selectedPin
            do {
                try self.dataController.viewContext.save()
            } catch {
                fatalError("Failed create Photo")
            }
        }
        self.downloadImages()
    }
    
}
