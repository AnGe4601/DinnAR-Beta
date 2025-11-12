//
//  MapViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 11/9/25.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapSetUp()
        
        // test
        restaurants = [
            Restaurant(
                name: "Test Café",
                cuisine: "Coffee",
                stars: "⭐️⭐️⭐️⭐️",
                imageURL: nil,
                reviews: "120 reviews",
                priceLevel: "$$",
                distance: "0.5 mi",
                location: "Austin",
                lat: 30.2675,
                long: -97.7429
            )
        ]
        addRestaurants()
    }
    
    // centering map around Austin
    func mapSetUp() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        mapView.setRegion(region, animated: true)
    }
    
    func addRestaurants() {
        let geocoder = CLGeocoder()
        
        for restaurant in restaurants {
            geocoder.geocodeAddressString(restaurant.location) { [weak self] placemarks, error in
                guard let self = self else { return }
                
                if let coordinate = placemarks?.first?.location?.coordinate {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = restaurant.name
                    annotation.subtitle = restaurant.cuisine
                    self.mapView.addAnnotation(annotation)
                } else if let error = error {
                    print("Geocoding failed for \(restaurant.name): \(error.localizedDescription)")
                }
            }
        }
    }
    /*
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            if let selectedRestaurant = restaurants.first(where: { $0.name == annotation.title }) {
                performSegue(withIdentifier: "showRestaurantDetail", sender: selectedRestaurant)
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showRestaurantDetail",
               let dest = segue.destination as? RestaurantInfoViewController,
               let restaurant = sender as? Restaurant {
                dest.restaurant = restaurant
            }
        }
     */

}

