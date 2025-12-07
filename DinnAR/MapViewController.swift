//
//  MapViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 11/9/25.
//

import UIKit
import MapKit
import CoreLocation

// Custome annotation type for restaurant annotation
class RestaurantAnnotation: NSObject, MKAnnotation {
    let restaurant: Restaurant
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.long)
        self.title = restaurant.name
        self.subtitle = restaurant.cuisine
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupSegmentControl()
        mapSetUp()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMapData),
            name: ResturantDataManager.didUpdateRestaurants,
            object: nil
        )
        
        self.restaurants = ResturantDataManager.shared.fetchedRestaurants
        addRestaurants()

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
    }
    
    @objc func updateMapData() {
        print("Map received updated restaurant list")
        self.restaurants = ResturantDataManager.shared.fetchedRestaurants
        mapView.removeAnnotations(mapView.annotations)
        addRestaurants()
    }
    
    // Initial map interface set up
    func mapSetUp() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
    }
    
    func addRestaurants() {
        mapView.removeAnnotations(mapView.annotations)
        for r in restaurants {
            guard r.lat != 0, r.long != 0 else { continue }
            let annotation = RestaurantAnnotation(restaurant: r)
            mapView.addAnnotation(annotation)
        }
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation { return nil }

        guard let restaurantAnnotation = annotation as? RestaurantAnnotation else {
            return nil
        }

        let identifier = "RestaurantPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true

            // Your custom icon
            view?.image = UIImage(systemName: "fork.knife.circle.fill")
            view?.tintColor = UIColor.burntOrange

            // Add disclosure button
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view?.annotation = annotation
        }

        return view
    }
    
    // Handle Button Tap
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        guard let annotation = view.annotation as? RestaurantAnnotation else { return }
        
        let selectedRestaurant = annotation.restaurant

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "RestaurantInfoViewController"
        ) as! RestaurantInfoViewController
        
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissRestaurantInfo)
        )
        
        let navVC = UINavigationController(rootViewController: vc)
        vc.restaurant = selectedRestaurant

        present(navVC, animated: true)
    }

    @objc func dismissRestaurantInfo() {
        dismiss(animated: true)
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

