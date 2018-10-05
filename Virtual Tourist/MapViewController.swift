//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 04/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
       
        // Do any additional setup after loading the view.
    }
    

    
    
    @IBAction func addNewLocation(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state != .began {
            return
        }
        let locationScreen  = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(locationScreen, toCoordinateFrom: self.mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        
        self.mapView.addAnnotation(annotation)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueDetailViewController") {
            if let navigation = segue.destination as? UINavigationController {
                if let detail = navigation.viewControllers.first as? DetailViewController {
                    detail.modalTransitionStyle = .crossDissolve
                    if let annotation = sender as? MKAnnotation {
                        detail.annotation = annotation
                    }
                    
                }
            }
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let aleert = UIAlertController.init(title: "", message: "", preferredStyle: .alert);
        let actionOK = UIAlertAction.init(title: "", style: .cancel, handler: nil)
        aleert.addAction(actionOK)
       // self.present(aleert, animated: true, completion: nil)
        self.performSegue(withIdentifier: "segueDetailViewController", sender: view.annotation)
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
 
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView .setCenter(userLocation.coordinate, animated: true)
    }
}

