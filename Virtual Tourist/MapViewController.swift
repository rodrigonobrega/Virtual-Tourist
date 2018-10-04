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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
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
        annotation.title = "teste"
        annotation.subtitle = "d¬_¬b"
        self.mapView.addAnnotation(annotation)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueDetailViewController") {
            if let navigation = segue.destination as? UINavigationController {
                if let detail = navigation.viewControllers.first as? DetailViewController {
                    
                    detail.annotation = (sender as! MKAnnotation)
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
