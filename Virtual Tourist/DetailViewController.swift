//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 04/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var annotation: MKAnnotation!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
       

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: @selector(close:))
        
        // Do any additional setup after loading the view.
        
//        annotation.canShowCallout = true
        
        
        guard let annotation = annotation else {
            
            return
        }

        
        
    
        
        self.mapView .addAnnotation(annotation)
        let latitude:CLLocationDegrees =  annotation.coordinate.latitude//insert latitutde
        
        let longitude:CLLocationDegrees = annotation.coordinate.longitude//insert longitude
        
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        
        let reg = MKCoordinateRegion(center: location, latitudinalMeters: 500000, longitudinalMeters: 500000)
       // let region = MKCoordinateRegion(center: location, span: span)
        
         mapView.setRegion(reg, animated: true)
        
//
//        CLLocationCoordinate2D noLocation;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
//        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
//        [self.mapView setRegion:adjustedRegion animated:YES];
//        let latitude:CLLocationDegrees =  annotation.coordinate.latitude//insert latitutde
//
//        let longitude:CLLocationDegrees = annotation.coordinate.longitude//insert longitude
//
//        let latDelta:CLLocationDegrees = 0.05
//
//        let lonDelta:CLLocationDegrees = 0.05
//
//        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
//
//        let location = CLLocationCoordinate2DMake(latitude, longitude)
//
//        let region = MKCoordinateRegion(center: location, span: span)
//
//       // self.mapView.showsUserLocation = true
//
//
//        mapView.setRegion(region, animated: false)
        
    }
    
    
    @IBAction func close(){
        self.dismiss(animated: true, completion: nil)
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
