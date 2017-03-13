//
//  GooglePlace.swift
//  nearby
//
//  Created by Mitosis on 02/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GooglePlace {
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    var photoReference: String?
    var photo: UIImage?
    
    init(dictionary:[String : AnyObject], acceptedTypes: [String])
    {
        let json = JSON(dictionary)
        name = json["name"].stringValue
        address = json["vicinity"].stringValue
        
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        print(lat)
        print(lng)
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        print(coordinate)
        photoReference = json["photos"][0]["photo_reference"].string
        print(photoReference)
        
        var foundType = "restaurant"
        let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
        for type in json["types"].arrayObject as! [String] {
            print(type)
            if possibleTypes.contains(type) {
                foundType = type
                break
            }
        }
        placeType = foundType
    }
}
