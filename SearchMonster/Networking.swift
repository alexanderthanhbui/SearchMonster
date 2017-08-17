//
//  Networking.swift
//  SearchMonster
//
//  Created by Hayne Park on 8/16/17.
//  Copyright © 2017 Alexander Bui. All rights reserved.
//

import Foundation
import CoreLocation

class Networking : NSObject {

    // Google textSearch API
    func getGooglePlaceInfo(searchTerm: String, completionHandler: @escaping (_ success: [PlaceObject]?, _ error: NSError?) -> Void) {
        
        // creating the url and request
        let methodParameters = [
            Constants.GoogleParameterKeys.query: searchTerm,
            Constants.GoogleParameterKeys.key: Constants.GoogleParameterValues.key
        ] as [String : Any]
        
        let urlString = Constants.Google.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        print(urlString)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                
                if let data = data {
                    
                    let parsedResult: [String:AnyObject]!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    } catch {
                        print("Could not parse the data as JSON: '\(data)'")
                        return
                    }
                    
                    if let jsonDictionary = parsedResult["results"] as? [[String:AnyObject]] {
                        
                        var placeObjects = [PlaceObject]()
                        
                        for jsonObject in jsonDictionary {
                            
                            var id = ""
                            var name = ""
                            var formattedAddress = ""
                            var open = Bool()
                            var photoRef = ""
                            var latitude = Double()
                            var longitude = Double()
                            
                            // id
                            if let objectId = jsonObject["id"] as? String {
                                id = objectId
                            }
                           
                            // name
                            if let objectName = jsonObject["name"] as? String {
                                name = objectName
                            }
                            
                            // address
                            if let objectFormattedAddress = jsonObject["formatted_address"] as? String {
                                formattedAddress = objectFormattedAddress
                            }
                            
                            // open
                            if let objectOpenHours = jsonObject["opening_hours"] as? [String: AnyObject],
                                let objectOpen = objectOpenHours["open_now"] as? Bool {
                                open = objectOpen
                            }
                            
                            // photos
                            if let objectPhotos = jsonObject["photos"] as? [[String: AnyObject]] {
                                for object in objectPhotos {
                                    if let objectPhotoRef = object["photo_reference"] as? String {
                                        photoRef = objectPhotoRef
                                    }
                                }
                            }
                            
                            // latitude and longitude
                            if let objectGeomentry = jsonObject["geometry"] as? [String: AnyObject],
                                let objectLocation = objectGeomentry["location"] as? [String: AnyObject],
                                let objectLatitude = objectLocation["lat"] as? Double,
                                let objectLongitude = objectLocation["lng"] as? Double {
                                latitude = objectLatitude
                                longitude = objectLongitude
                            }
                            
                            placeObjects.append(PlaceObject(id: id, name: name, formattedAddress: formattedAddress, open: open, photoRef: photoRef, latitude: latitude, longitude: longitude))
                            
                            
                        }
                        completionHandler(placeObjects, nil)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // Google photo API | credit to 
    // https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    
    func getGooglePhoto(url: URL, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            completionHandler(data, response, error)
            }.resume()
    }
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Networking {
        struct Singleton {
            static var sharedInstance = Networking()
        }
        return Singleton.sharedInstance
    }

}
