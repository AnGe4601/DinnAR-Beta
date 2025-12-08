import UIKit

protocol RecommendationCellDelegate: AnyObject {
    func didToggleFavorite(for restaurant: Restaurant)
    func didToggleVisited(for restaurant: Restaurant)
    func didTapFriendsButton(for restaurant: Restaurant, from cell: RecommendationCell)
}


class RecommendationCell: UITableViewCell {
    
    // individual cell labels
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var heartButton: UIButton!

    weak var delegate: RecommendationCellDelegate?
    var restaurant: Restaurant?

    private var currentImageURL: String?

    // MARK: - Hard-coded SF Symbol Icon
    private let friendsIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: config))
        iv.tintColor = .burntOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true // very important to detect taps
        return iv
    }()


    // MARK: - Cell Init
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupFriendsIcon()
    }

    private func setupUI() {
        restaurantImageView.layer.cornerRadius = 10
        restaurantImageView.layer.masksToBounds = true
        restaurantImageView.contentMode = .scaleAspectFill
        restaurantImageView.layer.borderWidth = 0.3
        restaurantImageView.layer.borderColor = UIColor.systemGray4.cgColor

        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        starsLabel.textColor = .systemOrange
        reviewsLabel.textColor = .systemGray
        cuisineLabel.textColor = .darkGray
        locationLabel.textColor = .systemGray
        distanceLabel.textColor = .systemGray
        priceLabel.textColor = UIColor(red: 0.93, green: 0.45, blue: 0.18, alpha: 1)

        heartButton.tintColor = UIColor(named: "BurntOrange")
        selectionStyle = .none

        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        contentView.backgroundColor = .systemBackground

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    // MARK: - Add Hard-coded Icon
    private func setupFriendsIcon() {
        contentView.addSubview(friendsIcon)
        
        // Example constraints: top-right corner with padding
        NSLayoutConstraint.activate([
            friendsIcon.centerYAnchor.constraint(equalTo: heartButton.centerYAnchor),
            friendsIcon.trailingAnchor.constraint(equalTo: heartButton.leadingAnchor, constant: -8), // 8pt gap
            friendsIcon.widthAnchor.constraint(equalToConstant: 24),
            friendsIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(friendsIconTapped))
        friendsIcon.addGestureRecognizer(tapGesture)
    }


    @objc private func friendsIconTapped() {
        guard let restaurant = restaurant else { return }
        delegate?.didTapFriendsButton(for: restaurant, from: self)
    }

    // MARK: - Configure Cell
    func configure(with restaurant: Restaurant) {
        self.restaurant = restaurant
        nameLabel.text = restaurant.name
        cuisineLabel.text = restaurant.cuisine
        starsLabel.text = restaurant.stars
        reviewsLabel.text = restaurant.reviews
        priceLabel.text = restaurant.priceLevel
        distanceLabel.text = restaurant.distance
        locationLabel.text = restaurant.location

        updateHeartIcon()

        // Load image
        restaurantImageView.image = UIImage(named: "placeholder")

        if let urlString = restaurant.imageURL,
           let url = URL(string: urlString),
           urlString.starts(with: "http") {

            currentImageURL = urlString

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data,
                      error == nil,
                      let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {
                    if self.currentImageURL == urlString {
                        self.restaurantImageView.image = image
                    }
                }
            }.resume()
        }
    }

    // MARK: - Heart Button
    @IBAction func heartTapped(_ sender: Any) {
        guard let restaurant = restaurant else { return }
        delegate?.didToggleFavorite(for: restaurant)
        updateHeartIcon()
    }

    private func updateHeartIcon() {
        guard let restaurant = restaurant else { return }
        if FavoritesManager.shared.isFavorite(restaurant) {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        restaurantImageView.layer.cornerRadius = 10
    }
}

