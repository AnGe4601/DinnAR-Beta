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
    var resturants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapSetUp()
        // test
        resturants = [
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
        addResturants()
    }
    
    // centering map around Austin
    func mapSetUp() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
    }
    
    func addResturants() {
        for resturant in resturants {
            guard resturant.lat != 0.0, resturant.long != 0.0 else {
                continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: resturant.lat,
                longitude: resturant.long
            )
            annotation.title = resturant.name
            annotation.subtitle = resturant.cuisine
            mapView.addAnnotation(annotation)
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
