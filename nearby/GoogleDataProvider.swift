import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GoogleDataProvider {
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    let apiKey = "AIzaSyDTjI9K2dPa-cZEG2k5-nNjvjledbJMJgM"
    let radi = 3000.0
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GooglePlace]) -> Void)) -> ()
    {
        print("latitude:\(coordinate.latitude)")
        print(coordinate.longitude)
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        print(urlString)
        let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if let task = placesTask , task.taskIdentifier > 0 && task.state == .running {
            task.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            if let aData = data {
                let json = JSON(data:aData, options:JSONSerialization.ReadingOptions.mutableContainers, error:nil)
                if let results = json["results"].arrayObject as? [[String : AnyObject]] {
                    print(results)
                    for rawPlace in results {
                        let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
                        print(place)
                        placesArray.append(place)
                        print(placesArray)
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference) { image in
                                place.photo = image
                                
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(placesArray)
            }
        })
        placesTask?.resume()
    }
    
    
    func fetchPhotoFromReference(_ reference: String, completion: @escaping ((UIImage?) -> Void)) -> () {
        if let photo = photoCache[reference] as UIImage? {
            completion(photo)
        } else {
            let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(apiKey)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            session.downloadTask(with: URL(string: urlString)!, completionHandler: {url, response, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let url = url {
                    let downloadedPhoto = UIImage(data: try! Data(contentsOf: url))
                    self.photoCache[reference] = downloadedPhoto
                    DispatchQueue.main.async {
                        completion(downloadedPhoto)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }) .resume()
        }
    }
}

