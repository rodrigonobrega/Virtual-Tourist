//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 08/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//


// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
        static let SortType = "sort"
        static let Bbox = "bbox"
    }
    
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "80ba3694278d1449c82db675f4fcb766"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let Items = "21"
        static let Method = "flickr.photos.search"
        static let SortType = "random"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // Mark: Mapview location
    struct LocationData {
        static let location = "location"
        static let latitudeDelta = "latitudeDelta"
        static let longitudeDelta = "longituteDelta"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    // Mark: Error messages
    struct ErrorMessage {
        static let APINotDefined = "Please inform your API Key in Constants File before init"
        static let errorDescription = "Error Description :"
        static let TrySometime = "Please try again in sometime"
        static let DataNotFound = "Data not found, please try again in sometime"
        static let InvalidData = "Return invalid data, please try again in sometime"
        static let PhotoNotFound = "Cannot find photos, please try again in sometime"
    }
}
