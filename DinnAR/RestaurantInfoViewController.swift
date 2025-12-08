import UIKit

enum SourceVC {
    case home
    case favorites
    case visited
}


class RestaurantInfoViewController: UIViewController {
    
    // MARK: - Properties
    var restaurant: Restaurant?
    var sourceVC: SourceVC?
    private var isFavorite: Bool = false
    
    // Data from API
    private var menuItems: String = "No menu information available.\n\nPlease visit the restaurant's website or call for menu details."
    private var reviewsData: [[String: Any]] = []
    private var averageRating: Double = 0.0
    private var reviewCount: Int = 0
    private var phoneNumber: String?
    private var yelpURL: String?
    private var restaurantAddress: String?
    private var restaurantHours: String?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let restaurantImageView = UIImageView()
    private let nameLabel = UILabel()
    private let starsView = UIView()
    private let ratingLabel = UILabel()
    private let priceDistanceStack = UIStackView()
    private let descriptionLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Menu", "Reviews", "Info"])
    private let contentContainerView = UIView()
    private let menuTextView = UITextView()
    private let reviewsStackView = UIStackView()
    private let infoStackView = UIStackView()
    private let quickInfoStack = UIStackView()
    private let directionsButton = UIButton(type: .system)
    private let callButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let bottomButton = UIButton(type: .system)
    var onFavoriteToggle: ((Restaurant) -> Void)?
    var onVisitedToggle: (() -> Void)?


    
    private var contentContainerTopConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    // Initial setup when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up custom back button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
        
        view.backgroundColor = UIColor(red: 1, green: 0.98, blue: 0.96, alpha: 1)
        
        setupScrollView()
        setupUI()
        populateBasicInfo()
        setupStarsDisplay()
        
        updateFavoriteButton()
        setupVisitedButton()

        
        if let restaurant = restaurant {
            fetchYelpData(for: restaurant)
        }
    }
    
    @objc func backTapped() {
        if let nav = navigationController {
            if nav.viewControllers.first == self {
                dismiss(animated: true, completion: nil)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Setup Methods
    
    // Configures the main scroll view and content container
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // Calls all UI setup methods in order
    private func setupUI() {
        let padding: CGFloat = 20
        
        setupImageView(padding: padding)
        setupNameAndIcons(padding: padding)
        setupStarsContainer()
        setupBadges()
        setupDescription()
        setupSegmentedControl(padding: padding)
        setupContentContainer(padding: padding)
        setupMenuView()
        setupReviewsView()
        setupInfoView()
        setupActionButtons(padding: padding)
        setupBottomButton(padding: padding)
    }
    
    // Sets up the restaurant image view at the top
    private func setupImageView(padding: CGFloat) {
        restaurantImageView.contentMode = .scaleAspectFill
        restaurantImageView.layer.cornerRadius = 18
        restaurantImageView.clipsToBounds = true
        restaurantImageView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        restaurantImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(restaurantImageView)
        
        NSLayoutConstraint.activate([
            restaurantImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            restaurantImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            restaurantImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            restaurantImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // Sets up restaurant name label and friend/favorite icons
    private func setupNameAndIcons(padding: CGFloat) {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        nameLabel.textColor = UIColor(red: 0.14, green: 0.14, blue: 0.13, alpha: 1)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: restaurantImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: -60)
        ])
        
        // Favorite icon
        shareButton.setImage(UIImage(systemName: "heart"), for: .normal)
        shareButton.tintColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 1.0)
        shareButton.backgroundColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 0.15)
        shareButton.layer.cornerRadius = 22
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            shareButton.trailingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // Sets up the star rating view and rating label
    private func setupStarsContainer() {
        let starsContainer = UIStackView(arrangedSubviews: [starsView, ratingLabel])
        starsContainer.axis = .horizontal
        starsContainer.spacing = 8
        starsContainer.alignment = .center
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(starsContainer)
        
        starsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starsView.heightAnchor.constraint(equalToConstant: 24),
            starsView.widthAnchor.constraint(equalToConstant: 130)
        ])
        
        ratingLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        ratingLabel.textColor = .darkGray
        ratingLabel.text = "No ratings yet"
        
        NSLayoutConstraint.activate([
            starsContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            starsContainer.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    // Sets up price and distance badges
    private func setupBadges() {
        priceDistanceStack.axis = .horizontal
        priceDistanceStack.spacing = 8
        priceDistanceStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceDistanceStack)
        
        NSLayoutConstraint.activate([
            priceDistanceStack.topAnchor.constraint(equalTo: starsView.superview!.bottomAnchor, constant: 10),
            priceDistanceStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    // Sets up the cuisine description label
    private func setupDescription() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: priceDistanceStack.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    // Sets up the Menu/Reviews/Info segmented control
    private func setupSegmentedControl(padding: CGFloat) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(red: 1, green: 0.98, blue: 0.96, alpha: 1)
        segmentedControl.selectedSegmentTintColor = .white
        
        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ]
        segmentedControl.setTitleTextAttributes(normalAttr, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttr, for: .selected)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        contentView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 14),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // Sets up the container that holds menu/reviews/info content
    private func setupContentContainer(padding: CGFloat) {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainerView)
        
        let topConstraint = contentContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8)
        self.contentContainerTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            topConstraint,
            contentContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            contentContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
    
    // Sets up the menu text view
    private func setupMenuView() {
        menuTextView.layer.cornerRadius = 12
        menuTextView.isEditable = false
        menuTextView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        menuTextView.font = UIFont.systemFont(ofSize: 15)
        menuTextView.textColor = UIColor(red: 0.23, green: 0.23, blue: 0.21, alpha: 1)
        menuTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        menuTextView.translatesAutoresizingMaskIntoConstraints = false
        menuTextView.isScrollEnabled = false
        menuTextView.dataDetectorTypes = [.link, .phoneNumber]
        menuTextView.text = menuItems
        menuTextView.textContainer.lineFragmentPadding = 0
        contentContainerView.addSubview(menuTextView)
        
        NSLayoutConstraint.activate([
            menuTextView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            menuTextView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            menuTextView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            menuTextView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    // Sets up the reviews stack view
    private func setupReviewsView() {
        reviewsStackView.axis = .vertical
        reviewsStackView.spacing = 12
        reviewsStackView.translatesAutoresizingMaskIntoConstraints = false
        reviewsStackView.isHidden = true
        contentContainerView.addSubview(reviewsStackView)
        
        NSLayoutConstraint.activate([
            reviewsStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            reviewsStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            reviewsStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            reviewsStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    // Sets up the info stack view
    private func setupInfoView() {
        infoStackView.axis = .vertical
        infoStackView.spacing = 12
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.isHidden = true
        contentContainerView.addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            infoStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            infoStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            infoStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    // Sets up Directions and Call buttons
    private func setupActionButtons(padding: CGFloat) {
        quickInfoStack.axis = .horizontal
        quickInfoStack.spacing = 10
        quickInfoStack.distribution = .fillEqually
        quickInfoStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quickInfoStack)
        
        NSLayoutConstraint.activate([
            quickInfoStack.topAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: 14),
            quickInfoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            quickInfoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            quickInfoStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        directionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        directionsButton.setTitleColor(UIColor.systemOrange, for: .normal)
        directionsButton.layer.cornerRadius = 10
        directionsButton.addTarget(self, action: #selector(openDirections), for: .touchUpInside)
        quickInfoStack.addArrangedSubview(directionsButton)
        
        callButton.setTitle("Call", for: .normal)
        callButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        callButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        callButton.setTitleColor(UIColor.systemOrange, for: .normal)
        callButton.layer.cornerRadius = 10
        callButton.addTarget(self, action: #selector(callRestaurant), for: .touchUpInside)
        quickInfoStack.addArrangedSubview(callButton)
    }
    
    // Sets up the Mark Visited button at the bottom
    private func setupBottomButton(padding: CGFloat) {
        bottomButton.setTitle("Mark Visited", for: .normal)
        bottomButton.backgroundColor = UIColor.systemOrange
        bottomButton.setTitleColor(.white, for: .normal)
        bottomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        bottomButton.layer.cornerRadius = 12
        bottomButton.clipsToBounds = true
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.addTarget(self, action: #selector(markVisitedTapped), for: .touchUpInside)
        contentView.addSubview(bottomButton)
        
        
        NSLayoutConstraint.activate([
            bottomButton.topAnchor.constraint(equalTo: quickInfoStack.bottomAnchor, constant: 22),
            bottomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            bottomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            bottomButton.heightAnchor.constraint(equalToConstant: 46),
            bottomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    // Property to track visited state
    private var isVisited = false

    private func setupVisitedButton() {
        // Load visited state
        updateVisitedState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateVisitedState()   // refresh visited button every time page appears
    }

    @objc private func markVisitedTapped() {
        guard let restaurant = restaurant else { return }
        
        // Toggle visited with Firestore sync
        VisitedManager.shared.toggleVisited(restaurant) { [weak self] error in
            guard let self = self else { return }
            
            // Update local state
            let isVisited = VisitedManager.shared.isVisited(restaurant)
            
            // Update button UI immediately
            let title = isVisited ? "Visited" : "Mark Visited"
            let bgColor = isVisited ? UIColor.burntOrange : UIColor.systemOrange
            
            DispatchQueue.main.async {
                self.bottomButton.setTitle(title, for: .normal)
                self.bottomButton.backgroundColor = bgColor
            }
            
            if let error = error {
                print("Error updating Firestore: \(error)")
            }
            
            self.onVisitedToggle?()
        }
    }

    private func updateVisitedState() {
        guard let restaurant = restaurant else { return }
        
        isVisited = VisitedManager.shared.isVisited(restaurant)
        
        let title = isVisited ? "Visited" : "Mark Visited"
        let bgColor = isVisited ? UIColor.burntOrange : UIColor.systemOrange
        
        bottomButton.setTitle(title, for: .normal)
        bottomButton.backgroundColor = bgColor
    }
    
    // MARK: - Data Population
    
    // Populates UI with basic restaurant info (name, cuisine, badges, image)
    private func populateBasicInfo() {
        guard let restaurant = restaurant else { return }
        
        nameLabel.text = restaurant.name
        descriptionLabel.text = restaurant.cuisine
        
        let priceBadge = createBadge(text: restaurant.priceLevel, bgColor: UIColor.systemOrange.withAlphaComponent(0.15))
        priceDistanceStack.addArrangedSubview(priceBadge)
        
        let distanceBadge = createBadge(text: restaurant.distance, bgColor: UIColor.systemOrange.withAlphaComponent(0.15))
        priceDistanceStack.addArrangedSubview(distanceBadge)
        
        if let urlString = restaurant.imageURL,
           let url = URL(string: urlString),
           urlString.starts(with: "http") {
            loadImage(from: url)
        }
    }
    
    // Initializes the stars display with empty stars
    private func setupStarsDisplay() {
        starsView.subviews.forEach { $0.removeFromSuperview() }
        updateStarsDisplay()
    }
    
    // Updates the star rating display based on current rating data
    private func updateStarsDisplay() {
        starsView.subviews.forEach { $0.removeFromSuperview() }
        
        let starCount = 5
        let starSize: CGFloat = 24
        let spacing: CGFloat = 3
        
        for i in 0..<starCount {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: CGFloat(i) * (starSize + spacing), y: 0, width: starSize, height: starSize)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = UIColor(red: 0.97, green: 0.58, blue: 0.11, alpha: 1)
            
            let starIndex = Double(i + 1)
            if averageRating >= starIndex {
                imageView.image = UIImage(systemName: "star.fill")
            } else if averageRating > starIndex - 1 {
                imageView.image = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                imageView.image = UIImage(systemName: "star")
            }
            
            starsView.addSubview(imageView)
        }
        
        if reviewCount > 0 {
            ratingLabel.text = String(format: "%.1f (%d reviews)", averageRating, reviewCount)
        } else {
            ratingLabel.text = "No ratings yet"
        }
    }
    
    // Refreshes the reviews display with current review data
    private func updateReviewsDisplay() {
        reviewsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if reviewsData.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No reviews available yet.\n\nBe the first to review this restaurant!"
            emptyLabel.font = UIFont.systemFont(ofSize: 15)
            emptyLabel.textColor = .darkGray
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            reviewsStackView.addArrangedSubview(emptyLabel)
        } else {
            for reviewData in reviewsData.prefix(3) {
                if let userName = reviewData["userName"] as? String,
                   let rating = reviewData["rating"] as? Int,
                   let reviewText = reviewData["text"] as? String {
                    let reviewCard = createReviewCard(userName: userName, rating: rating, reviewText: reviewText)
                    reviewsStackView.addArrangedSubview(reviewCard)
                }
            }
        }
    }
    
    // Updates the info tab with available restaurant information
    private func updateInfoDisplay() {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let yelpURL = yelpURL {
            let yelpCard = createInfoCard(title: "YELP PAGE", content: "Open in Yelp", isButton: true, action: #selector(openYelpPage))
            infoStackView.addArrangedSubview(yelpCard)
        }
    }
    
    // MARK: - Helper Methods
    
    // Creates a rounded badge with text (for price and distance)
    private func createBadge(text: String, bgColor: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = bgColor
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor.systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    // Creates a review card with user name, rating stars, and review text
    private func createReviewCard(userName: String, rating: Int, reviewText: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = userName
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.14, green: 0.14, blue: 0.13, alpha: 1)
        
        let starsContainer = UIView()
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let starSize: CGFloat = 16
        let starSpacing: CGFloat = 2
        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.frame = CGRect(x: CGFloat(i) * (starSize + starSpacing), y: 0, width: starSize, height: starSize)
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = UIColor.systemOrange
            starImageView.image = i < rating ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            starsContainer.addSubview(starImageView)
        }
        
        NSLayoutConstraint.activate([
            starsContainer.widthAnchor.constraint(equalToConstant: CGFloat(5) * (starSize + starSpacing)),
            starsContainer.heightAnchor.constraint(equalToConstant: starSize)
        ])
        
        headerStack.addArrangedSubview(nameLabel)
        headerStack.addArrangedSubview(starsContainer)
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = reviewText
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(textLabel)
        cardView.addSubview(headerStack)
        cardView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            headerStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            scrollView.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return cardView
    }
    
    // Creates an info card with a title and content (for either text or button)
    private func createInfoCard(title: String, content: String, isButton: Bool = false, action: Selector? = nil) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(titleLabel)
        
        if isButton {
            let button = UIButton(type: .system)
            button.setTitle(content, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            button.setTitleColor(UIColor.systemOrange, for: .normal)
            button.contentHorizontalAlignment = .left
            button.translatesAutoresizingMaskIntoConstraints = false
            if let action = action {
                button.addTarget(self, action: action, for: .touchUpInside)
            }
            
            cardView.addSubview(button)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                
                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                button.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                button.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
            ])
        } else {
            let contentLabel = UILabel()
            contentLabel.text = content
            contentLabel.font = UIFont.systemFont(ofSize: 15)
            contentLabel.textColor = UIColor(red: 0.23, green: 0.23, blue: 0.21, alpha: 1)
            contentLabel.numberOfLines = 0
            contentLabel.translatesAutoresizingMaskIntoConstraints = false
            
            cardView.addSubview(contentLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                
                contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                contentLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
            ])
        }
        
        return cardView
    }
    
    // Downloads and displays the restaurant image from a URL
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.restaurantImageView.image = image
                }
            }
        }.resume()
    }
    
    // Converts 24-hour time format for restaurant timing if available (doesn't show up right now because of API, will fix for Final)
    private func formatTime(_ time: String) -> String {
        guard time.count == 4,
              let hour = Int(time.prefix(2)),
              let minute = Int(time.suffix(2)) else {
            return time
        }
        
        let isPM = hour >= 12
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let period = isPM ? "PM" : "AM"
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
    
    // MARK: - Actions
    
    // Toggles favorite status and animates the heart button
    @objc private func shareButtonTapped() {
        guard let restaurant = restaurant else { return }
        
        // Toggle in FavoritesManager
        FavoritesManager.shared.toggleFavorite(restaurant)
        
        // Update local state
        updateFavoriteButton()

        // Animate the heart
        UIView.animate(withDuration: 0.2) {
            self.shareButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.shareButton.transform = .identity
            }
        }
        
        // Update image
        let imageName = isFavorite ? "heart.fill" : "heart"
        shareButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        onFavoriteToggle?(restaurant)
    }
    
    private func updateFavoriteButton() {
        guard let restaurant = restaurant else { return }
        
        isFavorite = FavoritesManager.shared.isFavorite(restaurant)
        let imageName = isFavorite ? "heart.fill" : "heart"
        shareButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // Handles segmented control changes to switch between Menu, Reviews, and Info
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Menu
            menuTextView.isHidden = false
            reviewsStackView.isHidden = true
            infoStackView.isHidden = true
            contentContainerTopConstraint.constant = 8
        case 1: // Reviews
            menuTextView.isHidden = true
            reviewsStackView.isHidden = false
            infoStackView.isHidden = true
            contentContainerTopConstraint.constant = 8
        case 2: // Info
            menuTextView.isHidden = true
            reviewsStackView.isHidden = true
            infoStackView.isHidden = false
            contentContainerTopConstraint.constant = 8
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Opens Apple Maps with directions to the restaurant - may change if implementing directional map into app
    @objc private func openDirections() {
        guard let restaurant = restaurant else { return }
        let address = restaurant.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?daddr=\(address)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Initiates a phone call to the restaurant
    @objc private func callRestaurant() {
        guard let phone = phoneNumber else {
            let alert = UIAlertController(title: "No Phone Number", message: "This restaurant doesn't have a phone number listed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let cleanedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanedPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    // Opens the restaurant's Yelp page in Safari
    @objc private func openYelpPage() {
        guard let yelpURL = yelpURL, let url = URL(string: yelpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - API Integration
    
    // Initiates Yelp search to fetch restaurant data
    private func fetchYelpData(for restaurant: Restaurant) {
        let apiKey = "97905f766b9efca118fc3e7d9a91e1acae701ffbbd145cc333e645da2517e53c"
        let location = restaurant.location.isEmpty ? "Austin, TX" : restaurant.location
        let query = "\(restaurant.name) \(location)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let urlString = "https://serpapi.com/search.json?engine=yelp&find_desc=\(encodedQuery)&find_loc=Austin,TX&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            self.processYelpSearchData(json, for: restaurant)
        }.resume()
    }
    
    // Processes Yelp search results and pull rating, reviews, and place ID
    private func processYelpSearchData(_ json: [String: Any], for restaurant: Restaurant) {
        guard let organicResults = json["organic_results"] as? [[String: Any]],
              let firstResult = organicResults.first else {
            return
        }
        
        if let rating = firstResult["rating"] as? Double {
            self.averageRating = rating
            DispatchQueue.main.async {
                self.updateStarsDisplay()
            }
        }
        
        if let reviews = firstResult["reviews"] as? Int {
            self.reviewCount = reviews
            DispatchQueue.main.async {
                self.updateStarsDisplay()
            }
        }
        
        if let phone = firstResult["phone"] as? String {
            self.phoneNumber = phone
        }
        
        if let link = firstResult["link"] as? String {
            self.yelpURL = link
            DispatchQueue.main.async {
                self.updateInfoDisplay()
            }
        }
        
        if let placeIDs = firstResult["place_ids"] as? [String],
           let placeID = placeIDs.first {
            self.fetchYelpPlaceDetails(placeID: placeID, for: restaurant)
        }
    }
    
    // Fetches detailed place information and reviews from Yelp
    private func fetchYelpPlaceDetails(placeID: String, for restaurant: Restaurant) {
        let apiKey = "97905f766b9efca118fc3e7d9a91e1acae701ffbbd145cc333e645da2517e53c"
        
        let placeURL = "https://serpapi.com/search.json?engine=yelp_place&place_id=\(placeID)&api_key=\(apiKey)"
        
        if let url = URL(string: placeURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    return
                }
                
                self.processYelpPlaceData(json, for: restaurant)
            }.resume()
        }
        
        let reviewsURL = "https://serpapi.com/search.json?engine=yelp_reviews&place_id=\(placeID)&api_key=\(apiKey)"
        
        guard let url = URL(string: reviewsURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            self.processYelpReviewsData(json, for: restaurant)
        }.resume()
    }

    // Processes place details including address, phone, hours, and menu
    private func processYelpPlaceData(_ json: [String: Any], for restaurant: Restaurant) {
        if let address = json["address"] as? String {
            self.restaurantAddress = address
        } else if let location = json["location"] as? [String: Any] {
            var addressParts: [String] = []
            if let address1 = location["address1"] as? String { addressParts.append(address1) }
            if let city = location["city"] as? String,
               let state = location["state"] as? String,
               let zipCode = location["zip_code"] as? String {
                addressParts.append("\(city), \(state) \(zipCode)")
            }
            if !addressParts.isEmpty {
                self.restaurantAddress = addressParts.joined(separator: "\n")
            }
        }
        
        if let phone = json["phone"] as? String ?? json["display_phone"] as? String {
            self.phoneNumber = phone
        }
        
        if let hours = json["hours"] as? [[String: Any]], !hours.isEmpty {
            var hoursText = ""
            if let regularHours = hours.first?["open"] as? [[String: Any]] {
                for day in regularHours {
                    if let dayNum = day["day"] as? Int,
                       let start = day["start"] as? String,
                       let end = day["end"] as? String {
                        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        let dayName = dayNum < dayNames.count ? dayNames[dayNum] : "Day \(dayNum)"
                        
                        let startFormatted = formatTime(start)
                        let endFormatted = formatTime(end)
                        hoursText += "\(dayName): \(startFormatted) - \(endFormatted)\n"
                    }
                }
            }
            if !hoursText.isEmpty {
                self.restaurantHours = hoursText.trimmingCharacters(in: .newlines)
            }
        }
        
        var menuLink: String?
        if let menuDict = json["menu"] as? [String: Any] {
            menuLink = menuDict["url"] as? String ?? menuDict["link"] as? String
        } else if let menuURL = json["menu_url"] as? String {
            menuLink = menuURL
        }
        
        if let menuLink = menuLink {
            DispatchQueue.main.async {
                self.menuItems = "VIEW MENU\n\n\(menuLink)\n\nTap the link above or use the Call button to contact the restaurant for menu details."
                self.menuTextView.text = self.menuItems
            }
        }
        
        DispatchQueue.main.async {
            self.updateInfoDisplay()
        }
    }
    
    private func processYelpReviewsData(_ json: [String: Any], for restaurant: Restaurant) {
        if let reviews = json["reviews"] as? [[String: Any]], !reviews.isEmpty {
            var reviewsArray: [[String: Any]] = []
            
            for review in reviews.prefix(3) {
                var reviewDict: [String: Any] = [:]
                
                if let rating = review["rating"] as? Int {
                    reviewDict["rating"] = rating
                } else if let rating = review["rating"] as? Double {
                    reviewDict["rating"] = Int(rating)
                }
                
                if let user = review["user"] as? [String: Any],
                   let userName = user["name"] as? String {
                    reviewDict["userName"] = userName
                }
                
                var commentText = ""
                if let comment = review["comment"] as? [String: Any],
                   let text = comment["text"] as? String {
                    commentText = text
                } else if let text = review["text"] as? String {
                    commentText = text
                } else if let excerpt = review["excerpt"] as? String {
                    commentText = excerpt
                }
                
                if !commentText.isEmpty {
                    reviewDict["text"] = commentText
                }
                
                if !reviewDict.isEmpty {
                    reviewsArray.append(reviewDict)
                }
            }
            
            if !reviewsArray.isEmpty {
                self.reviewsData = reviewsArray
                DispatchQueue.main.async {
                    self.updateReviewsDisplay()
                }
            }
        }
    }
}
