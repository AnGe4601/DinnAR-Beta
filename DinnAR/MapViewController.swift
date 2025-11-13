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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupSegmentControl()
        /*  test
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
         */
        mapSetUp()
        
        fetchRestaurants(query: "restaurants in Austin")
    }
    
    func mapSetUp() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
    }
    
    func fetchRestaurants(query: String) {
        let apiKey = "82d6e2c51201426737573e6ea30569f9db91afcd7bed48520ce651746eb88a6d"
        let fullQuery = "\(query) in Austin, TX"
        let encodedQuery = fullQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fullQuery
        let urlString = "https://serpapi.com/search.json?engine=google_local&q=\(encodedQuery)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        print("Fetching map data from: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var results: [[String: Any]] = []
                    
                    if let localResults = json["local_results"] as? [[String: Any]] {
                        results = localResults
                    } else if let mapResults = json["local_map_results"] as? [[String: Any]] {
                        results = mapResults
                    }
                    
                    guard !results.isEmpty else {
                        print("No restaurants found.")
                        return
                    }
                    
                    var fetchedRestaurants: [Restaurant] = []
                    for item in results.prefix(15) { // up to 15 pins
                        let name = item["title"] as? String ?? "Unknown"
                        let cuisine = item["type"] as? String ?? "Restaurant"
                        let rating = item["rating"] as? Double ?? 0.0
                        let stars = String(repeating: "⭐️", count: Int(rating.rounded()))
                        let reviews = "\(item["reviews"] ?? "0") reviews"
                        let priceLevel = item["price"] as? String ?? "$$"
                        let location = item["address"] as? String ?? "Austin"
                        let gps = item["gps_coordinates"] as? [String: Any]
                        let lat = gps?["latitude"] as? Double ?? 0.0
                        let long = gps?["longitude"] as? Double ?? 0.0
                        
                        fetchedRestaurants.append(Restaurant(
                            name: name,
                            cuisine: cuisine,
                            stars: stars,
                            imageURL: item["thumbnail"] as? String,
                            reviews: reviews,
                            priceLevel: priceLevel,
                            distance: "",
                            location: location,
                            lat: lat,
                            long: long
                        ))
                    }
                    
                    DispatchQueue.main.async {
                        self.resturants = fetchedRestaurants
                        self.addRestaurants()
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Add Map Pins
    func addRestaurants() {
        for restaurant in resturants {
            guard restaurant.lat != 0.0, restaurant.long != 0.0 else { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.long)
            annotation.title = restaurant.name
            annotation.subtitle = restaurant.cuisine
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "RestaurantPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            annotationView?.image = UIImage(systemName: "fork.knife.circle.fill")
            annotationView?.tintColor = UIColor.burntOrange
            
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // MARK: - Segmented Control
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 2
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        guard let storyboard = storyboard else { return }
        var vcToPresent: UIViewController?
        
        switch sender.selectedSegmentIndex {
        case 0:
            vcToPresent = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        case 1:
            vcToPresent = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        case 2:
            return
        case 3:
            vcToPresent = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        default:
            return
        }
        
        if let vc = vcToPresent {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
}

