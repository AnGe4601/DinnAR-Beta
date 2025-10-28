//  MainViewController.swift
//  FavoritesView
// Swathi Rudravajjala (smr5498)


import UIKit

// Main Tab Bar Controller
class AppTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize tabs
        let homeVC = PlaceholderViewController(title: "DinnAR")
        let locationVC = PlaceholderViewController(title: "DinnAR")
        let bookmarkVC = MainViewController() // Favorites + Visited Restaurants
        let settingsVC = PlaceholderViewController(title: "DinnAR")
        
        // Set tab bar items (only images, no labels)
        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), tag: 0)
        locationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "map.fill"), tag: 1)
        bookmarkVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bookmark.fill"), tag: 2)
        settingsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape.fill"), tag: 3)
        
        // Hide tab bar labels
        [homeVC, locationVC, bookmarkVC, settingsVC].forEach { vc in
            vc.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 1000)
        }
        
        // Tab bar appearance
        tabBar.tintColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 1.0) // Orange fill
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .systemGray6
        tabBar.isTranslucent = false
        
        // Assign view controllers inside navigation controllers
        viewControllers = [homeVC, bookmarkVC, locationVC, settingsVC].map { UINavigationController(rootViewController: $0) }
    }
}

// Placeholder View Controller
class PlaceholderViewController: UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        view.backgroundColor = .systemBackground
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// Favorites + Visited Restaurants Screen
class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0xFD/255.0, green: 0xF7/255.0, blue: 0xF0/255.0, alpha: 1.0) // Custom background
        title = "DinnAR"
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // MARK: - Favorites Section
        contentStack.addArrangedSubview(makeSectionHeader(title: "Your Favorites", systemImage: "heart"))
        
        // Duplicate a card 5 times for scrolling demonstration
        for _ in 0..<5 {
            contentStack.addArrangedSubview(makeRestaurantCard(name: "Favorite Restaurant"))
        }

        // MARK: - Visited Restaurants Section
        contentStack.addArrangedSubview(makeSectionHeader(title: "Visited Restaurants", systemImage: "mappin"))
        
        // Duplicate a card 5 times for scrolling demonstration
        for _ in 0..<5 {
            contentStack.addArrangedSubview(makeRestaurantCard(name: "Visited Restaurant"))
        }

        // MARK: - ScrollView Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }


    // Section Header
    private func makeSectionHeader(title: String, systemImage: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let icon = UIImageView(image: UIImage(systemName: systemImage))
        icon.tintColor = .black
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    // Restaurant Card
    private func makeRestaurantCard(name: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 120).isActive = true

        // Image placeholder
        let imageView = UIView()
        imageView.backgroundColor = .systemGray4
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(imageView)

        // Buttons
        let menuButton = makeOptionButton(title: "Menu")
        menuButton.addTarget(self, action: #selector(menuTapped(_:)), for: .touchUpInside)
        let callButton = makeOptionButton(title: "Call")
        callButton.addTarget(self, action: #selector(callTapped(_:)), for: .touchUpInside)
        let directionsButton = makeOptionButton(title: "Directions")
        directionsButton.addTarget(self, action: #selector(directionsTapped(_:)), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [menuButton, callButton, directionsButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(buttonStack)

        // Name label
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // Constraints
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            buttonStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            buttonStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            buttonStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    // Option Button
    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    // Button Actions
    @objc private func menuTapped(_ sender: UIButton) { print("Menu tapped") }
    @objc private func callTapped(_ sender: UIButton) { print("Call tapped") }
    @objc private func directionsTapped(_ sender: UIButton) { print("Directions tapped") }
}
