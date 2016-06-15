//
//  ViewController.swift
//  GoToJail
//
//  Created by Mohamed Ayadi on 6/15/16.
//  Copyright © 2016 Mohamed Ayadi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barTintColor = UIColor.redColor()
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            textView.text = "Location found. Reverse geocoding."
            reverseGeocode(location!)
            locationManager.stopUpdatingLocation()
        }
    }
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            let placemark = placemarks?.first
            if let subThoroughfare = placemark?.subThoroughfare {
                let address = "\(subThoroughfare) \n\(placemark!.thoroughfare!)\n\(placemark!.locality!)"
            self.textView.text = "Found you at \(address)"
            self.findJailNear(location)
        }
    }
}
    func findJailNear(location: CLLocation) {
        let request = MKLocalSearchRequest()
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1))
        request.naturalLanguageQuery = "correctional"
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response:MKLocalSearchResponse?, error: NSError?) in
            let mapItems = response?.mapItems
            let mapItem = mapItems?.first!
            self.textView.text = "Go directly to \(mapItem!.name!)"
            self.getDirectionsTo(mapItem!)
        }
    }
    
    func getDirectionsTo(destinationItem: MKMapItem) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destinationItem
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) in
            let routes = response?.routes
            let route = routes?.first
            var x = 1
            let directionString = NSMutableString()
            for step in (route?.steps)! {
                print(step.instructions)
                directionString.appendString("\(x). \(step.instructions)\n")
                x+=1
            }
            self.textView.text = directionString as String
        }

    }

    @IBAction func giveInfo(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }

}

