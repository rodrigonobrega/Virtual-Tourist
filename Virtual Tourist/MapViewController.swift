//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 04/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    static let segueDetailViewController = "segueDetailViewController"
    static let kSortDescriptorKey = "name"
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var dataController:DataController!
  
    var pins:[Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    fileprivate func setup() {
        loadInitialPosition()
        mapView.delegate = self
        mapView.showsUserLocation = true
        self.loadPins()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            mapView.showsUserLocation = true
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func loadInitialPosition() {
        if let locationDictionary = UserDefaults.standard.value(forKey: Constants.LocationData.location) as? NSDictionary {
            
            let center = CLLocationCoordinate2D(
                latitude: locationDictionary.value(forKey: Constants.LocationData.latitude) as! CLLocationDegrees,
                longitude: locationDictionary.value(forKey: Constants.LocationData.longitude) as! CLLocationDegrees)
            
            let span = MKCoordinateSpan(
                latitudeDelta: locationDictionary.value(forKey: Constants.LocationData.latitudeDelta) as! CLLocationDegrees,
                longitudeDelta: locationDictionary.value(forKey: Constants.LocationData.longitudeDelta) as! CLLocationDegrees)
            
            mapView.region.span = span
            mapView.region.center = center
            
        }
    }
    
    func loadPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: MapViewController.kSortDescriptorKey, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        }
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func addNewLocation(_ sender: UILongPressGestureRecognizer) {
        if (Constants.FlickrParameterValues.APIKey == "") {
            
            let alert = UIAlertController(title: "Virtual Tourist", message: Constants.ErrorMessage.APINotDefined, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        if sender.state != .began {
            return
        }
        
        let locationScreen  = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(locationScreen, toCoordinateFrom: self.mapView)
        
        let pin:Pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        try? dataController.viewContext.save()
        
        pins.insert(pin, at: 0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        
        self.mapView.addAnnotation(annotation)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if (segue.identifier == MapViewController.segueDetailViewController) {
            let navigation = segue.destination as! UINavigationController
            let detail = navigation.viewControllers.first as! PhotoAlbumViewController
            detail.modalTransitionStyle = .crossDissolve
            detail.dataController = self.dataController
            if let selectedPin = sender as? Pin {
                detail.selectedPin = selectedPin
            }
            
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for pin in pins {
            let pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            if pinCoordinate == view.annotation?.coordinate {
                self.performSegue(withIdentifier: MapViewController.segueDetailViewController, sender: pin)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        VirtualTouristService.sharedInstance().updateUserLocation(mapView: mapView)
    }
    
}

// MARK: - CLLocationCoordinate2D extension to compare coordinate
extension CLLocationCoordinate2D: Equatable {
    
    static public func ==(firstLocation: CLLocationCoordinate2D, secondLocation: CLLocationCoordinate2D) -> Bool {
        return (firstLocation.latitude == secondLocation.latitude && firstLocation.longitude == secondLocation.longitude)
    }
}


