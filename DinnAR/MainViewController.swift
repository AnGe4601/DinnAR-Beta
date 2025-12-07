//  MainViewController.swift
//  FavoritesView
//  Swathi Rudravajjala (smr5498)
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    var visitedFirestore: Firestore?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var favorites: [Restaurant] = []
    var visited: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentControl()
        setupTableView()
        setupTableViewConstraints()
        loadData()
        
        if let visitedApp = FirebaseApp.app(name: "VisitedApp") {
            visitedFirestore = Firestore.firestore(app: visitedApp)
        } else {
            print("VisitedApp not configured")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupTableViewConstraints() {
        // Disable autoresizing mask
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -47)
        ])
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

    func loadData() {
        VisitedManager.shared.fetchVisited { [weak self] visited in
            self?.visited = visited
            self?.tableView.reloadData()
        }

        FavoritesManager.shared.fetchFavorites { [weak self] favorites in
            self?.favorites = favorites
            self?.tableView.reloadData()
        }
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
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as!MapViewController
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "Favorites" : "Visited"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return favorites.count
        } else {
            return visited.count
        }
    }

    // MARK: - Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as? RecommendationCell else {
            fatalError("Cell not found")
        }
            
        let restaurant = (indexPath.section == 0)
            ? favorites[indexPath.row]
            : visited[indexPath.row]

        cell.configure(with: restaurant)
        cell.delegate = self
        return cell
    }
        
    // MARK: - Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant: Restaurant?
        
        if indexPath.section == 0 {
            restaurant = (indexPath.row < favorites.count) ? favorites[indexPath.row] : nil
        } else {
            restaurant = (indexPath.row < visited.count) ? visited[indexPath.row] : nil
        }

        guard let selectedRestaurant = restaurant else { return }
        performSegue(withIdentifier: "showRestaurantInfo", sender: selectedRestaurant)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantInfo",
           let restaurant = sender as? Restaurant,
           let nav = segue.destination as? UINavigationController,
           let destVC = nav.viewControllers.first as? RestaurantInfoViewController {
            
            destVC.restaurant = restaurant
            
            // Determine source for onVisitedToggle if needed
            if favorites.contains(where: { $0.name == restaurant.name && $0.location == restaurant.location }) {
                destVC.sourceVC = .favorites
            } else {
                destVC.sourceVC = .visited
            }
            
            // Reload data when visited is toggled
            destVC.onVisitedToggle = { [weak self] in
                guard let self = self else {return}
                self.loadData()
                self.tableView.reloadData()
            }
        }
    }
}

extension MainViewController: RecommendationCellDelegate {
    func didToggleFavorite(for restaurant: Restaurant) {
        FavoritesManager.shared.toggleFavorite(restaurant) { [weak self] error in
            if let error = error { print(error) }
            self?.loadData() // reload table after toggling
        }
    }

    func didToggleVisited(for restaurant: Restaurant) {
        VisitedManager.shared.toggleVisited(restaurant) { [weak self] error in
            if let error = error {
                print("Error toggling visited: \(error)")
            } else {
                // Reload table on main thread
                DispatchQueue.main.async {
                    self?.loadData()
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

