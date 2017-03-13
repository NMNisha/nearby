//
//  ViewController.swift
//  nearby
//
//  Created by Mitosis on 02/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController  {
    
    @IBOutlet var markerView: UIImageView!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    let locationManager = CLLocationManager()
    let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 3000
    var locationMarker = GMSMarker()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
    }
    

        
    
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TypesTableViewController
            controller.selectedTypes = searchedTypes
            controller.delegate = self
        }
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
          
            self.addressLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines 
                self.addressLabel.text = lines?.joined(separator: "\n")
                
                let labelHeight = self.addressLabel.intrinsicContentSize.height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                
               self.addressLabel.layer.opacity = 1
                self.view.addSubview(self.addressLabel)
                print(coordinate)
                  self.setMarker(coordinate: coordinate)
                
                
            }
        }
    }
    
    func setMarker(coordinate: CLLocationCoordinate2D) {
        
        let pos = coordinate
        print(pos)
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = mapView
        locationMarker.title = "You are Here"
        locationMarker.snippet = "You are here"
        locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
        locationMarker.opacity = 0.75
    }
    
    func fetchNearbyPlaces(_ coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            for place: GooglePlace in places {
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: AnyObject) {
        fetchNearbyPlaces(mapView.camera.target)
    }
    
}

// MARK: - TypesTableViewControllerDelegate
extension ViewController: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true, completion: nil)
        fetchNearbyPlaces(mapView.camera.target)
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 8, bearing: 0, viewingAngle: 0)
          
          
            
            locationManager.stopUpdatingLocation()
            fetchNearbyPlaces(location.coordinate)
        }
        
    }
}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel.lock()
        
        if (gesture) {
          //  markerView.opacity = 1.0
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        let placeMarker = marker as! PlaceMarker
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.name
            
            if let photo = placeMarker.place.photo {
                infoView.placePhoto.image = photo
            } else {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        marker.opacity = 0
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
       // markerView.map = mapView
      // markerView.opacity = 1
        mapView.selectedMarker = nil
        return false
    }
}
