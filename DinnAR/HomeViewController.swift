import UIKit

struct Restaurant: Equatable {
    var name: String
    var cuisine: String
    var stars: String
    var imageURL: String?
    var reviews: String
    var priceLevel: String
    var distance: String
    var location: String
    var lat: Double
    var long: Double

    // Google data
    var description: String?
    var rating: String?
    var weeklyHours: String?
    var website: String?
    var address: String?

    // Yelp details (for RestaurantInfoVC)
    var yelpID: String?
    var yelpReviews: [String]?
    var yelpMenu: [String]?
    var yelpWaitTime: String?
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: break // Already on Home
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        default: break
        }
    }
    
    // search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // recommended restaurants table view
    @IBOutlet weak var tableView: UITableView!
    
    var recommendations: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
        segmentControl.tintColor = UIColor.gray
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.rowHeight = 120
        
        fetchRestaurants(query: "restaurants in austin")
    }
    
    // MARK: - SerpAPI Integration
    func fetchRestaurants(query: String) {
        let apiKey = "82d6e2c51201426737573e6ea30569f9db91afcd7bed48520ce651746eb88a6d"
        let fullQuery = "\(query) in Austin, TX"
        let encodedQuery = fullQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fullQuery
        let urlString = "https://serpapi.com/search.json?engine=google_local&q=\(encodedQuery)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        print("Fetching from: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("AHH Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("AHH No data received.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorMessage = json["error"] as? String {
                        print("SerpAPI Error: \(errorMessage)")
                    }
                    
                    var results: [[String: Any]] = []
                    
                    // Updated SerpAPI path for google_local results
                    if let localResults = json["local_results"] as? [[String: Any]] {
                        results = localResults
                    } else if let mapResults = json["local_map_results"] as? [[String: Any]] {
                        results = mapResults
                    }
                    
                    guard !results.isEmpty else {
                        print("Oops no live results found — using demo data.")
                        let demoRestaurants = [
                            Restaurant(name: "Debug Placeholder Café", cuisine: "Italian", stars: "⭐️⭐️⭐️⭐️", imageURL: nil, reviews: "120 reviews", priceLevel: "$$", distance: "0.5 mi", location: "Austin", lat: 30.2599, long: 97.7402),
                            Restaurant(name: "Taco Haven", cuisine: "Mexican", stars: "⭐️⭐️⭐️⭐️⭐️", imageURL: nil, reviews: "230 reviews", priceLevel: "$", distance: "1.1 mi", location: "Austin", lat: 26.0203, long: 80.2856),
                            Restaurant(name: "Coffee Verde", cuisine: "Vegan", stars: "⭐️⭐️⭐️⭐️", imageURL: nil, reviews: "89 reviews", priceLevel: "$$", distance: "0.8 mi", location: "Austin", lat: 14.69, long: 121)
                        ]
                        DispatchQueue.main.async {
                            self.recommendations = demoRestaurants
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                    var fetchedRestaurants: [Restaurant] = []
                    for item in results.prefix(6) {
                        let name = item["title"] as? String ?? "Unknown"
                        let cuisine = item["type"] as? String ?? "Restaurant"
                        let rating = item["rating"] as? Double ?? 0.0
                        let stars = String(repeating: "⭐️", count: Int(rating.rounded()))
                        let imageURL = item["thumbnail"] as? String
                        let reviews = "\(item["reviews"] ?? "0") reviews"
                        let priceLevel = item["price"] as? String ?? "$$"
                        let distance = item["distance"] as? String ?? "\(String(format: "%.1f", Double.random(in: 0.2...2.0))) mi"
                        let location = item["address"] as? String ?? "Austin"
                        let gps = item["gps_coordinates"] as? [String: Any]
                        let lat = gps?["latitude"] as? Double ?? 0.0
                        let long = gps?["longitude"] as? Double ?? 0.0
                        
                        fetchedRestaurants.append(Restaurant(
                            name: name,
                            cuisine: cuisine,
                            stars: stars,
                            imageURL: imageURL,
                            reviews: reviews,
                            priceLevel: priceLevel,
                            distance: distance,
                            location: location,
                            lat: lat,
                            long: long
                        ))
                    }
                    
                    DispatchQueue.main.async {
                        self.recommendations = fetchedRestaurants
                        self.tableView.reloadData()
                    }
                } else {
                    print("AHH JSON parsing failed or no results.")
                }
            } catch {
                print("AHH Failed to decode JSON: \(error)")
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
        cell.delegate = self
        return cell
    }
    
    // function that helps perform segue onto next tab
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showRestaurantInfo", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantInfo",
           let indexPath = sender as? IndexPath {
            let selectedRestaurant = recommendations[indexPath.row]
            
            if let navController = segue.destination as? UINavigationController,
               let destVC = navController.viewControllers.first as? RestaurantInfoViewController {
                destVC.restaurant = selectedRestaurant
                destVC.sourceVC = .home
            }
        }
    }

}

extension HomeViewController: RecommendationCellDelegate {
    func didToggleFavorite(for restaurant: Restaurant) {
        FavoritesManager.shared.toggleFavorite(restaurant)
        if let index = recommendations.firstIndex(of: restaurant) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
