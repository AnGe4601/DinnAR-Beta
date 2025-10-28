//
//  HomeViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/28/25.
//

import UIKit

struct Restaurant {
    let name: String
    let cuisine: String
    let stars: String
    let imageName: String
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // restaurant recommendation label
    @IBOutlet weak var recommendationLabel: UILabel!
    
    // near you label
    @IBOutlet weak var nearYouLabel: UILabel!
    
    // first nearby restaurant and distance label
    @IBOutlet weak var nearRestaurantLabel1: UILabel!
    @IBOutlet weak var distanceLabel1: UILabel!
    
    // second nearby restaurant and distance label
    @IBOutlet weak var nearRestaurantLabel2: UILabel!
    @IBOutlet weak var distanceLabel2: UILabel!
    
    // recommended restaurants table view
    @IBOutlet weak var tableView: UITableView!
    
    
    // example data inputs
    let recommendations: [Restaurant] = [
        Restaurant(name: "Aba - Austin", cuisine: "Mediterranean • South Congress", stars: "⭐️⭐️⭐️⭐️⭐️", imageName: "aba"),
        Restaurant(name: "Red Ash Italia", cuisine: "Italian • Downtown", stars: "⭐️⭐️⭐️⭐️⭐️", imageName: "redash"),
        Restaurant(name: "De Nada Cantina", cuisine: "Mexican • East Austin", stars: "⭐️⭐️⭐️⭐️", imageName: "denada")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 120
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }

    // function to add recommendation cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell
        let restaurant = recommendations[indexPath.row]
        cell.configure(with: restaurant)
        return cell
    }
    
    // function that helps perform segue onto next tab
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showRestaurantInfo", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantInfo" {
            if let indexPath = sender as? IndexPath {
                let selectedRestaurant = recommendations[indexPath.row]
                let destVC = segue.destination as! RestaurantInfoViewController
                destVC.restaurant = selectedRestaurant
            }
        }
    }

}

