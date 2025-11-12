//  MainViewController.swift
//  FavoritesView
//  Swathi Rudravajjala (smr5498)
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var favorites: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentControl()
        setupTableView()
        loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }

    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 1 // Favorites tab
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 120
        tableView.tableFooterView = UIView() // remove empty separators
    }

    func loadFavorites() {
        favorites = FavoritesManager.shared.favorites
        tableView.reloadData()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 1:
            break // Already on Favorites
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        default:
            break
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.isEmpty {
            let label = UILabel()
            label.text = "No favorites yet!"
            label.textAlignment = .center
            tableView.backgroundView = label
            return 0
        } else {
            tableView.backgroundView = nil
            return favorites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as? RecommendationCell else {
            fatalError("Cell not found")
        }
        
        let restaurant = favorites[indexPath.row]
        cell.configure(with: restaurant)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showRestaurantInfo", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantInfo",
           let indexPath = sender as? IndexPath {
            let selectedRestaurant = favorites[indexPath.row]
            
            // Check if destination is a navigation controller
            if let navController = segue.destination as? UINavigationController,
               let destVC = navController.viewControllers.first as? RestaurantInfoViewController {
                destVC.restaurant = selectedRestaurant
                destVC.sourceVC = .favorites
            }
        }
    }
}

extension MainViewController: RecommendationCellDelegate {
    func didToggleFavorite(for restaurant: Restaurant) {
        FavoritesManager.shared.toggleFavorite(restaurant)
        loadFavorites()
    }
}
