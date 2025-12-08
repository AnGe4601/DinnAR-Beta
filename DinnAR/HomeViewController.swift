import UIKit

struct Restaurant: Codable, Equatable {
    var name: String
    var cuisine: String?
    var stars: String
    var imageURL: String?
    var reviews: String
    var priceLevel: String
    var distance: String
    var location: String
    var lat: Double
    var long: Double
    var visited: Bool = false

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

extension Restaurant {
    var dictionary: [String: Any] {
        return [
            "name": name,
            "location": location,
            "cuisine": cuisine ?? ""
        ]
    }
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
    private var isUsingPreferences = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
        segmentControl.tintColor = UIColor.gray
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.rowHeight = 120
        
        tableView.contentInsetAdjustmentBehavior = .never
        searchBar.setContentHuggingPriority(.required, for: .vertical)
        
        
        checkAndLoadRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        tableView.layoutIfNeeded()
        tableView.reloadData()
        
        // Reload with preferences if user changed preferences
        if UserPreferencesManager.shared.hasCompletedOnboarding() && isUsingPreferences {
            loadRestaurantsBasedOnPreferences()
        }
    }
    
    func mapAPIDataToRestaurant(apiData: [String: Any]) -> Restaurant {
        return Restaurant(
            name: apiData["name"] as? String ?? "",
            cuisine: apiData["cuisine"] as? String,
            stars: apiData["stars"] as? String ?? "",
            imageURL: apiData["imageURL"] as? String,
            reviews: apiData["reviews"] as? String ?? "",
            priceLevel: apiData["priceLevel"] as? String ?? "",
            distance: apiData["distance"] as? String ?? "",
            location: apiData["location"] as? String ?? "",
            lat: apiData["lat"] as? Double ?? 0,
            long: apiData["long"] as? Double ?? 0
        )
    }
    
    // MARK: - Preference Loading
    
    private func checkAndLoadRestaurants() {
        if UserPreferencesManager.shared.hasCompletedOnboarding() {
            loadRestaurantsBasedOnPreferences()
        } else {
            // No preferences set - show generic results
            fetchRestaurants(query: "restaurants in austin")
        }
    }
    
    private func loadRestaurantsBasedOnPreferences() {
        let preferences = UserPreferencesManager.shared
        
        // Build query from preferences
        var queryComponents: [String] = []
        
        // Add cuisine types
        let cuisines = preferences.getCuisineTypes()
        if !cuisines.isEmpty && !cuisines.contains("All") {
            queryComponents.append(contentsOf: cuisines)
        }
        
        // Add restaurant types
        let restaurantTypes = preferences.getRestaurantTypes()
        if !restaurantTypes.isEmpty && !restaurantTypes.contains("All") {
            queryComponents.append(contentsOf: restaurantTypes)
        }
        
        // Add dietary restrictions
        let dietary = preferences.getDietaryRestrictions()
        if !dietary.isEmpty && !dietary.contains("None") {
            queryComponents.append(contentsOf: dietary)
        }
        
        // Build final query
        let query = queryComponents.isEmpty ? "restaurants" : queryComponents.joined(separator: " ")
        
        print("Searching with preferences: \(query)")
        fetchRestaurants(query: query)
        isUsingPreferences = true
    }
    
    private func showNoResultsForPreferences() {
        let alert = UIAlertController(
            title: "No Matches Found",
            message: "We couldn't find restaurants matching your preferences. Try searching manually or adjusting your preferences.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Search All", style: .default) { [weak self] _ in
            self?.fetchRestaurants(query: "restaurants in austin")
            self?.isUsingPreferences = false
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - SerpAPI Integration
    func fetchRestaurants(query: String) {
        
        let apiKey = "97905f766b9efca118fc3e7d9a91e1acae701ffbbd145cc333e645da2517e53c"
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
                        ResturantDataManager.shared.fetchedRestaurants = fetchedRestaurants
                        self.recommendations = fetchedRestaurants
                        self.tableView.reloadData()
                        
                        if fetchedRestaurants.isEmpty && self.isUsingPreferences {
                            self.showNoResultsForPreferences()
                        }
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
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        fetchRestaurants(query: searchText)
        isUsingPreferences = false
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
                
                // Use a closure to update the heart
                destVC.onFavoriteToggle = { [weak self] updatedRestaurant in
                    guard let self = self else { return }
                    if let index = self.recommendations.firstIndex(of: updatedRestaurant) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
}

// MARK: - RecommendationCellDelegate
extension HomeViewController: RecommendationCellDelegate {
    
    func didToggleFavorite(for restaurant: Restaurant) {
        FavoritesManager.shared.toggleFavorite(restaurant) { [weak self] error in
            guard let self = self else { return }
            if let error = error { print("Favorite toggle error:", error) }
            if let index = self.recommendations.firstIndex(of: restaurant) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func didToggleVisited(for restaurant: Restaurant) {
        VisitedManager.shared.toggleVisited(restaurant) { [weak self] error in
            guard let self = self else { return }
            if let error = error { print("Visited toggle error:", error) }
            if let index = self.recommendations.firstIndex(of: restaurant) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func didTapFriendsButton(for restaurant: Restaurant, from cell: RecommendationCell) {
        // Example: fake counts for demonstration
        let likedCount = 0
        let visitedCount = 0
        
        let message = """
        Liked by \(likedCount) friends
        Visited by \(visitedCount) friends
        """
        
        let alert = UIAlertController(title: restaurant.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


