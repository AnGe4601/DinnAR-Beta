import UIKit

class RestaurantInfoViewController: UIViewController {
    var restaurant: Restaurant?

    // MARK: - UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let nameLabel = UILabel()
    let starsView = UIView()
    let restaurantImageView = UIImageView()
    let priceDistanceStack = UIStackView()
    let descriptionLabel = UILabel()
    let quickInfoStack = UIStackView()
    let directionsButton = UIButton(type: .system)
    let callButton = UIButton(type: .system)
    let shareButton = UIButton(type: .system)
    let segmentedControl = UISegmentedControl(items: ["Menu", "Reviews", "Info"])
    let infoTextView = UITextView()
    let bottomButton = UIButton(type: .system)
    let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Data
    private var menuItems: String = "No menu information available.\n\nPlease visit the restaurant's website or call for menu details."
    private var reviewsText: String = "No reviews available yet.\n\nBe the first to review this restaurant!"
    private var infoText: String = "Loading restaurant information..."
    private var websiteURL: String?
    private var yelpURL: String?
    private var phoneNumber: String?
    private var userRating: Int = 0
    private var isFavorite: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 0.98, blue: 0.96, alpha: 1)
        setupScrollView()
        setupUI()
        setupLoadingIndicator()
        populateBasicInfo()
        setupInteractiveStars()
        
        if let restaurant = restaurant {
            fetchGooglePlacesData(for: restaurant)
            fetchYelpData(for: restaurant)
        }
    }
    
    // MARK: - Loading Indicator
    func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .systemOrange
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - SCROLL VIEW AND LAYOUT
    func setupScrollView() {
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

    // MARK: - UI SETUP
    func setupUI() {
        let padding: CGFloat = 20

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
        
        // Favorite + Friend icons
        let friendIconView = UIImageView(image: UIImage(systemName: "person.2.fill"))
        friendIconView.tintColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 1.0) // same orange tone
        friendIconView.contentMode = .scaleAspectFit
        friendIconView.translatesAutoresizingMaskIntoConstraints = false

        shareButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        shareButton.tintColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 1.0)
        shareButton.backgroundColor = UIColor(red: 0xBA/255.0, green: 0x39/255.0, blue: 0x02/255.0, alpha: 0.15)
        shareButton.layer.cornerRadius = 22
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        // Stack both icons horizontally
        let iconStack = UIStackView(arrangedSubviews: [friendIconView, shareButton])
        iconStack.axis = .horizontal
        iconStack.spacing = 8
        iconStack.alignment = .center
        iconStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconStack)

        // Layout constraints for icon stack
        NSLayoutConstraint.activate([
            iconStack.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            iconStack.trailingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor),

            friendIconView.widthAnchor.constraint(equalToConstant: 28),
            friendIconView.heightAnchor.constraint(equalToConstant: 28),

            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        starsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(starsView)
        NSLayoutConstraint.activate([
            starsView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            starsView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsView.heightAnchor.constraint(equalToConstant: 30),
            starsView.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        // Price & Distance badges
        priceDistanceStack.axis = .horizontal
        priceDistanceStack.spacing = 8
        priceDistanceStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceDistanceStack)
        NSLayoutConstraint.activate([
            priceDistanceStack.topAnchor.constraint(equalTo: starsView.bottomAnchor, constant: 10),
            priceDistanceStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])

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
        
        // Segmented control (after description)
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

        // Info Text View - directly below segmented control with small gap
        infoTextView.layer.cornerRadius = 12
        infoTextView.isEditable = false
        infoTextView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        infoTextView.font = UIFont.systemFont(ofSize: 15)
        infoTextView.textColor = UIColor(red: 0.23, green: 0.23, blue: 0.21, alpha: 1)
        infoTextView.textContainerInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        infoTextView.isScrollEnabled = false
        contentView.addSubview(infoTextView)
        NSLayoutConstraint.activate([
            infoTextView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            infoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            infoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        // Quick action buttons (Directions, Call) - directly below text view
        quickInfoStack.axis = .horizontal
        quickInfoStack.spacing = 10
        quickInfoStack.distribution = .fillEqually
        quickInfoStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quickInfoStack)
        NSLayoutConstraint.activate([
            quickInfoStack.topAnchor.constraint(equalTo: infoTextView.bottomAnchor, constant: 14),
            quickInfoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            quickInfoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            quickInfoStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Directions button
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        directionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        directionsButton.setTitleColor(UIColor.systemOrange, for: .normal)
        directionsButton.layer.cornerRadius = 10
        directionsButton.addTarget(self, action: #selector(openDirections), for: .touchUpInside)
        quickInfoStack.addArrangedSubview(directionsButton)
        
        // Call button
        callButton.setTitle("Call", for: .normal)
        callButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        callButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        callButton.setTitleColor(UIColor.systemOrange, for: .normal)
        callButton.layer.cornerRadius = 10
        callButton.addTarget(self, action: #selector(callRestaurant), for: .touchUpInside)
        quickInfoStack.addArrangedSubview(callButton)

        // Mark Visited button
        bottomButton.setTitle("Mark Visited", for: .normal)
        bottomButton.backgroundColor = UIColor.systemOrange
        bottomButton.setTitleColor(.white, for: .normal)
        bottomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        bottomButton.layer.cornerRadius = 12
        bottomButton.clipsToBounds = true
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomButton)
        NSLayoutConstraint.activate([
            bottomButton.topAnchor.constraint(equalTo: quickInfoStack.bottomAnchor, constant: 22),
            bottomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            bottomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            bottomButton.heightAnchor.constraint(equalToConstant: 46),
            bottomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        infoTextView.text = menuItems
    }
    
    // MARK: - Helper to create badge
    func createBadge(text: String, bgColor: UIColor) -> UIView {
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

    // MARK: - Populate the basic stuff
    func populateBasicInfo() {
        guard let restaurant = restaurant else { return }
        nameLabel.text = restaurant.name
        descriptionLabel.text = restaurant.cuisine
        
        // Add price badge
        let priceBadge = createBadge(text: restaurant.priceLevel, bgColor: UIColor.systemOrange.withAlphaComponent(0.15))
        priceDistanceStack.addArrangedSubview(priceBadge)
        
        // Add distance badge
        let distanceBadge = createBadge(text: restaurant.distance, bgColor: UIColor.systemOrange.withAlphaComponent(0.15))
        priceDistanceStack.addArrangedSubview(distanceBadge)

        if let urlString = restaurant.imageURL,
           let url = URL(string: urlString),
           urlString.starts(with: "http") {
            loadImage(from: url)
        }
    }

    // MARK: - INTERACTIVE STARS (User can rate)
    func setupInteractiveStars() {
        starsView.subviews.forEach { $0.removeFromSuperview() }
        
        let starCount = 5
        let starSize: CGFloat = 28
        let spacing: CGFloat = 4
        
        for i in 0..<starCount {
            let button = UIButton(type: .system)
            button.tag = i + 1
            button.frame = CGRect(x: CGFloat(i) * (starSize + spacing), y: 0, width: starSize, height: starSize)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = UIColor(red: 0.97, green: 0.58, blue: 0.11, alpha: 1)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsView.addSubview(button)
        }
    }
    
    @objc func starTapped(_ sender: UIButton) {
        userRating = sender.tag
        updateStarDisplay()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func updateStarDisplay() {
        for view in starsView.subviews {
            if let button = view as? UIButton {
                let starIndex = button.tag
                if starIndex <= userRating {
                    button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    button.setImage(UIImage(systemName: "star"), for: .normal)
                }
            }
        }
    }

    // MARK: - GOOGLE PLACES DATA
    func fetchGooglePlacesData(for restaurant: Restaurant) {
        let apiKey = "dd319a412e42c0260813f3ed7c1a72666c0de0f9d1b0197b7ae8fa39f08a6e40"
        let location = restaurant.location.isEmpty ? "Austin, TX" : restaurant.location
        let query = "\(restaurant.name) \(location)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://serpapi.com/search.json?engine=google_maps&q=\(encodedQuery)&type=place&api_key=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching Google Places: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let placeResults = json["place_results"] as? [String: Any] {

                    let rating = placeResults["rating"] as? Double ?? 0.0
                    let website = placeResults["website"] as? String
                    let description = placeResults["description"] as? String ?? restaurant.cuisine
                    let openState = placeResults["open_state"] as? String ?? "Hours not available"
                    let address = placeResults["address"] as? String ?? restaurant.location
                    let phone = placeResults["phone"] as? String
                    self.phoneNumber = phone
                    
                    // Get detailed hours
                    var hoursText = openState
                    if let hours = placeResults["hours"] as? [[String: Any]] {
                        var hoursList: [String] = []
                        for day in hours {
                            if let dayName = day["day"] as? String,
                               let hoursString = day["hours"] as? String {
                                hoursList.append("\(dayName): \(hoursString)")
                            }
                        }
                        if !hoursList.isEmpty {
                            hoursText = hoursList.joined(separator: "\n")
                        }
                    }
                    
                    // Build info section with website URL
                    var infoDetails: [String] = []
                    infoDetails.append("📍 ADDRESS\n\(address)\n")
                    if let phone = phone {
                        infoDetails.append("📞 PHONE\n\(phone)\n")
                    }
                    infoDetails.append("⏰ HOURS\n\(hoursText)")
                    
                    if let website = website {
                        infoDetails.append("\n\n🌐 WEBSITE\n\(website)")
                        self.websiteURL = website
                    }
                    
                    // Check for menu
                    if let menu = placeResults["menu"] as? [String: Any],
                       let menuLink = menu["link"] as? String {
                        self.menuItems = "🍽️ VIEW MENU\n\n\(menuLink)\n\nTap the link above or use the Call button below to contact the restaurant for menu details."
                    }
                    
                    // Get reviews
                    if let userReviews = (placeResults["user_reviews"] as? [String: Any])?["summary"] as? [[String: Any]] {
                        let topReviews = userReviews.prefix(3).compactMap { review -> String? in
                            guard let snippet = review["snippet"] as? String,
                                  let rating = review["rating"] as? Double else { return nil }
                            let stars = String(repeating: "⭐️", count: Int(rating))
                            return "\(stars)\n\(snippet)"
                        }
                        if !topReviews.isEmpty {
                            self.reviewsText = "📝 TOP REVIEWS\n\n" + topReviews.joined(separator: "\n\n---\n\n")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        // Update description with cuisine and address
                        var descriptionText = description
                        if !address.isEmpty && address != self.restaurant?.location {
                            descriptionText += "\n📍 \(address)"
                        }
                        self.descriptionLabel.text = descriptionText
                        
                        self.infoText = infoDetails.joined(separator: "\n")
                        
                        if self.segmentedControl.selectedSegmentIndex == 0 {
                            self.infoTextView.text = self.menuItems
                        } else if self.segmentedControl.selectedSegmentIndex == 2 {
                            self.infoTextView.text = self.infoText
                        }
                        
                        self.loadingIndicator.stopAnimating()
                    }
                }
            } catch {
                print("Google Places JSON error: \(error)")
            }
        }.resume()
    }

    // MARK: - YELP DATA
    func fetchYelpData(for restaurant: Restaurant) {
        let apiKey = "dd319a412e42c0260813f3ed7c1a72666c0de0f9d1b0197b7ae8fa39f08a6e40"
        let location = restaurant.location.isEmpty ? "Austin, TX" : restaurant.location
        let query = "\(restaurant.name) \(location)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let urlString = "https://serpapi.com/search.json?engine=yelp&find_desc=\(encodedQuery)&find_loc=Austin,TX&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let organicResults = json["organic_results"] as? [[String: Any]],
                  let firstResult = organicResults.first else {
                return
            }
            
            if let link = firstResult["link"] as? String {
                self.yelpURL = link
                
                // Add Yelp URL to info if no website URL exists
                DispatchQueue.main.async {
                    if self.websiteURL == nil {
                        var currentInfo = self.infoText
                        currentInfo += "\n\n🌐 YELP PAGE\n\(link)"
                        self.infoText = currentInfo
                        
                        if self.segmentedControl.selectedSegmentIndex == 2 {
                            self.infoTextView.text = self.infoText
                        }
                    }
                }
            }
            
            if let placeIDs = firstResult["place_ids"] as? [String],
               let placeID = placeIDs.first {
                self.fetchYelpPlaceDetails(placeID: placeID)
            }
        }.resume()
    }
    
    func fetchYelpPlaceDetails(placeID: String) {
        let apiKey = "dd319a412e42c0260813f3ed7c1a72666c0de0f9d1b0197b7ae8fa39f08a6e40"
        let urlString = "https://serpapi.com/search.json?engine=yelp_place&place_id=\(placeID)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            // Extract menu if available
            if let fullMenuLink = json["full_menu"] as? String {
                DispatchQueue.main.async {
                    if self.menuItems.contains("No menu information available") {
                        self.menuItems = "🍽️ VIEW MENU\n\n\(fullMenuLink)\n\nTap the link above or use the Call button below to contact the restaurant for menu details."
                        if self.segmentedControl.selectedSegmentIndex == 0 {
                            self.infoTextView.text = self.menuItems
                        }
                    }
                }
            }
            
            // Extract reviews
            if let reviews = json["reviews"] as? [[String: Any]], !reviews.isEmpty {
                var reviewStrings: [String] = []
                for review in reviews.prefix(3) {
                    if let user = review["user"] as? [String: Any],
                       let userName = user["name"] as? String,
                       let comment = review["comment"] as? [String: Any],
                       let text = comment["text"] as? String,
                       let rating = review["rating"] as? Int {
                        
                        let stars = String(repeating: "⭐️", count: rating)
                        reviewStrings.append("\(stars) \(userName)\n\(text)")
                    }
                }
                if !reviewStrings.isEmpty {
                    DispatchQueue.main.async {
                        if self.reviewsText.contains("No reviews available") {
                            self.reviewsText = "📝 YELP REVIEWS\n\n" + reviewStrings.joined(separator: "\n\n---\n\n")
                            if self.segmentedControl.selectedSegmentIndex == 1 {
                                self.infoTextView.text = self.reviewsText
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
    @objc func shareButtonTapped() {
        isFavorite.toggle()
        
        // Animate and change icon
        UIView.animate(withDuration: 0.2) {
            self.shareButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.shareButton.transform = .identity
            }
        }
        
        let imageName = isFavorite ? "heart.fill" : "heart"
        shareButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: infoTextView.text = menuItems
        case 1: infoTextView.text = reviewsText
        case 2: infoTextView.text = infoText
        default: break
        }
    }
    
    @objc func openDirections() {
        guard let restaurant = restaurant else { return }
        let address = restaurant.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?daddr=\(address)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func callRestaurant() {
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

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.restaurantImageView.image = image
                }
            }
        }.resume()
    }
}
