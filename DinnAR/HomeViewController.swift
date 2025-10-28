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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // restaurant recommendation label
    @IBOutlet weak var recommendationLabel: UILabel!
    
    // near you label
    @IBOutlet weak var nearYouLabel: UILabel!

    // recommended restaurants table view
    @IBOutlet weak var tableView: UITableView!
    
    
    var recommendations: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.rowHeight = 120
        
        fetchRestaurants(query: "restaurants in austin")
    }

    // MARK: - SerpAPI Integration
    func fetchRestaurants(query: String) {
        let apiKey = "8490c18ba14dfd0fed86362051447ef3606cc22f51972eb4ea3fa8be858356fd"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
                let urlString = "https://serpapi.com/search.json?engine=google_maps&q=\(encodedQuery)&type=search&api_key=\(apiKey)"
                
                guard let url = URL(string: urlString) else { return }
                
                print("Fetching from: \(urlString)")
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error fetching data: \(error)")
                        return
                    }
                    
                    guard let data = data else { return }
                    do {
                        // Decode the JSON
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let results = json["local_results"] as? [[String: Any]] {
                            
                            var fetchedRestaurants: [Restaurant] = []
                            for item in results.prefix(5) { // limit to 5 for now
                                let name = item["title"] as? String ?? "Unknown"
                                let cuisine = item["type"] as? String ?? "Restaurant"
                                let rating = item["rating"] as? Double ?? 0.0
                                let stars = String(repeating: "⭐️", count: Int(rating.rounded()))
                                
                                fetchedRestaurants.append(Restaurant(name: name, cuisine: cuisine, stars: stars, imageName: "placeholder"))
                            }
                            
                            DispatchQueue.main.async {
                                self.recommendations = fetchedRestaurants
                                self.tableView.reloadData()
                            }
                        }
                    } catch {
                        print("Failed to decode JSON: \(error)")
                    }
                }.resume()
    }
    
    // MARK: - Search Function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {return}
        fetchRestaurants(query: searchText)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - TableView
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

