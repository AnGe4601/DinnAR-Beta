import UIKit

struct Restaurant {
    let name: String
    let cuisine: String
    let stars: String
    let imageURL: String?
    let reviews: String
    let priceLevel: String
    let distance: String
    let location: String
}


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["local_results"] as? [[String: Any]] {
                    
                    var fetchedRestaurants: [Restaurant] = []
                    for item in results.prefix(5) {
                        let name = item["title"] as? String ?? "Unknown"
                        let cuisine = item["type"] as? String ?? "Restaurant"
                        let rating = item["rating"] as? Double ?? 0.0
                        let stars = String(repeating: "⭐️", count: Int(rating.rounded()))
                        let imageURL = item["thumbnail"] as? String
                        let reviews = "\(item["reviews"] ?? "0") reviews"
                        let priceLevel = item["price"] as? String ?? "$$"
                        let distance = item["distance"] as? String ?? "\(String(format: "%.1f", Double.random(in: 0.2...2.0))) mi"
                        let location = item["address"] as? String ?? "Austin"
                        
                        fetchedRestaurants.append(Restaurant(
                            name: name,
                            cuisine: cuisine,
                            stars: stars,
                            imageURL: imageURL,
                            reviews: reviews,
                            priceLevel: priceLevel,
                            distance: distance,
                            location: location
                        ))
                    }
                    
                    DispatchQueue.main.async {
                        self.recommendations = fetchedRestaurants
                        self.tableView.reloadData()
                    }
                } else {
                    print("JSON parsing failed or no results.")
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
