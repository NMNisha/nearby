//
//  PlaceMarker.swift
//  nearby
//
//  Created by Mitosis on 02/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GoogleMapsCore

class PlaceMarker: GMSMarker {
    let place: GooglePlace
    
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: "Marker_25")
        groundAnchor = CGPoint(x: 0.5, y: 1)
    }
}
