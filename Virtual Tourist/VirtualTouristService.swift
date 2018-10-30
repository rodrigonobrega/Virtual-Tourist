//
//  VirtualTouristService.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 08/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VirtualTouristService {

    class func sharedInstance() -> VirtualTouristService {
        struct VirtualService {
            static var sharedInstance = VirtualTouristService()
        }
        return VirtualService.sharedInstance
    }
    
    
    func loadPhotosFromCoordinate(_ coordinate:CLLocationCoordinate2D, _ completion: @escaping ( _ success: Bool, _ message: String?, _ photos: [[String:AnyObject]]?) -> Void){
        
        let parameter = createDefaultParametersWithCoordinate(coordinate)
        
        let session = URLSession.shared
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(parameter as [String:AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                completion(false, error.debugDescription, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
                completion(false, Constants.ErrorMessage.TrySometime, nil)
                return
            }
            
            guard let data = data else {
                completion(false, Constants.ErrorMessage.DataNotFound, nil)
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                completion(false, Constants.ErrorMessage.InvalidData, nil)
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completion(false, "Flickr error(\(String(describing: parsedResult))). \n\(Constants.ErrorMessage.TrySometime)", nil)
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject],
                let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    completion(false, Constants.ErrorMessage.PhotoNotFound, nil)
                    return
            }
            
            completion(true, nil, photoArray)
            
            
        }
        
        
        task.resume()
    }
    
    func downloadImageFromUrl(urlString: String, completion: @escaping (_ success: Bool, _ data: Data?) -> Void) {
    
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        

        print("############ Start \(urlString)")
        URLSession.shared.dataTask(with: urlRequest , completionHandler: { (data, response, error) -> Void in
            if let data = data {
                print("############ Downloaded \(urlString)")
                completion(true, data)
            } else {
                
                print("############ ERRRORORORORORORORRO =============########")
                completion(false, nil)
            }
        }).resume()
    }
    
    func downloadImageFromPhoto(_ photo:Photo) {
        if let urlString = photo.url_m {
            //DispatchQueue.global(qos: .userInitiated).async {
                
                URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
                    if error == nil {
                        
                        DispatchQueue.main.async {
                            photo.binaryPhoto = data
                            try? photo.managedObjectContext?.save()
                        }
                        
                    }
                    
              //  }
                
                
            }.resume()
            //}
        }
        
    }
        
    func downloadImageFromPhotoolde(_ photo:Photo) {
        if let urlString = photo.url_m {
            
            let urlRequest = URLRequest(url: URL(string: urlString)!)
            
            
            
            URLSession.shared.dataTask(with: urlRequest , completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    photo.setValue(data, forKey: "binaryPhoto")
        
                    try? photo.managedObjectContext?.save()
                } else {
                    
                    print("############ ERRRORORORORORORORRO =============########")
                    
                }
            }).resume()
        } else {
            print("------------------------nunca")
        }
    }
    
    //save current user location
    func updateUserLocation(mapView: MKMapView) {

        let locationData = [
            Constants.LocationData.latitude:mapView.centerCoordinate.latitude
            , Constants.LocationData.longitude:mapView.centerCoordinate.longitude
            , Constants.LocationData.latitudeDelta:mapView.region.span.latitudeDelta
            , Constants.LocationData.longitudeDelta:mapView.region.span.longitudeDelta]
        UserDefaults.standard.set(locationData, forKey: Constants.LocationData.location)
        UserDefaults.standard.synchronize()
    }
    
}

// MARK: - VirtualTouristService extension - Util methods
extension VirtualTouristService {
    
    private func createDefaultParametersWithCoordinate(_ coordinate: CLLocationCoordinate2D) -> [String:Any?] {
        let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let randomPage = "\(UInt64(arc4random_uniform(50) + 1))"
        
        
        let methodParameters = [
            Constants.FlickrParameterKeys.PerPage:Constants.FlickrParameterValues.Items,
            Constants.FlickrParameterKeys.Page:randomPage,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.Method,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SortType:Constants.FlickrParameterValues.SortType,
            Constants.FlickrParameterKeys.Bbox: self.createBoxCoordinate(coordinate: coordinate),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        return methodParameters
    }
    
    private func createBoxCoordinate(coordinate:CLLocationCoordinate2D) -> String {
        
        let boxSize = 1.0
        let latitudeMinimum = -90.0
        let latitudeMaximum = 90.0
        let longitudeMinimum = -180.0
        let longitudeMaximum = 180.0
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - boxSize, longitudeMinimum)
        let bottom_left_lat = max(latitude - boxSize, latitudeMinimum)
        let top_right_lon = min(longitude + boxSize, longitudeMaximum)
        let top_right_lat = min(latitude + boxSize, latitudeMaximum)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    
    
    // MARK: Helper for Escaping Parameters in URL
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                if let stringValue = value as? String {
                    let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    keyValuePairs.append(key + "=" + "\(escapedValue!)")
                }
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
