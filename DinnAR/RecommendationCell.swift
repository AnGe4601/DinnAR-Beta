import UIKit

protocol RecommendationCellDelegate: AnyObject {
    func didToggleFavorite(for restaurant: Restaurant)
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
    var restaurant: Restaurant? {
        didSet {
            updateHeartIcon()
            updateLabels()
        }
    }
    private var currentImageURL: String?
    
    func updateLabels() {
        guard let restaurant = restaurant else { return } // safe unwrap
        nameLabel.text = restaurant.name
        cuisineLabel.text = restaurant.cuisine
    }

    // MARK: - Properties
    var isFavorite = false
    
    // Mark: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // image appearance
        restaurantImageView.layer.cornerRadius = 10
        restaurantImageView.layer.masksToBounds = true
        restaurantImageView.contentMode = .scaleAspectFill
        restaurantImageView.layer.borderWidth = 0.3
        restaurantImageView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // text styling
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        starsLabel.textColor = .systemOrange
        reviewsLabel.textColor = .systemGray
        cuisineLabel.textColor = .darkGray
        locationLabel.textColor = .systemGray
        distanceLabel.textColor = .systemGray
        priceLabel.textColor = UIColor(red: 0.93, green: 0.45, blue: 0.18, alpha: 1.0)
        
        // heart button color
        heartButton.tintColor = UIColor(named: "BurntOrange")
        selectionStyle = .none
        
        // Cell appearance
        selectionStyle = .none
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor // <- Black divider
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemBackground
        
        // Add subtle shadow for “card” look
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    // MARK: - configure function
    func configure(with restaurant: Restaurant) {
        self.restaurant = restaurant

        // backup image
        restaurantImageView.image = UIImage(named: "placeholder")
        
        // more text setup
        nameLabel.text = restaurant.name
        cuisineLabel.text = restaurant.cuisine
        starsLabel.text = restaurant.stars
        reviewsLabel.text = restaurant.reviews
        priceLabel.text = restaurant.priceLevel
        distanceLabel.text = restaurant.distance
        locationLabel.text = restaurant.location
        
        let ratingCount = restaurant.stars.filter { $0 == "⭐️" }.count
        updateStars(for: Double(ratingCount))
        
        // Load image from url
        if let urlString = restaurant.imageURL,
           let url = URL(string: urlString),
           urlString.starts(with: "http") {
            
            currentImageURL = urlString
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil,
                      let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    self.restaurantImageView.image = image
                    self.restaurantImageView.layer.cornerRadius = 10
                    self.restaurantImageView.layer.masksToBounds = true
                    self.restaurantImageView.layoutIfNeeded() // ensure correct frame
        
        
                }
            }.resume()
        }
        
        updateHeartIcon()

    }
    
    // MARK - star color change
    private func updateStars(for rating: Double) {
        let starCount = Int(rating.rounded())
        let starSymbol = "star.fill"
        let starAttachment = NSMutableAttributedString()
        
        for _ in 0..<starCount {
            if let image = UIImage(systemName: starSymbol)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal) {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = image
                imageAttachment.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
                starAttachment.append(NSAttributedString(attachment: imageAttachment))
                starAttachment.append(NSAttributedString(string: " "))
            }
        }
        
        starsLabel.attributedText = starAttachment
    }
    
    func updateHeartIcon() {
        guard let restaurant = restaurant else { return }
        if FavoritesManager.shared.isFavorite(restaurant) {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    // MARK: - heart button action function
    @IBAction func heartTapped(_ sender: Any) {
        guard let restaurant = restaurant else { return } // safe unwrap
        delegate?.didToggleFavorite(for: restaurant)
        updateHeartIcon() // update immediately after toggle
    }

    
    // MARK: - layout styling
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply rounded “card” look to contentView
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Apply consistent corner radius on image after Auto Layout
        restaurantImageView.layer.cornerRadius = 10
        restaurantImageView.layer.masksToBounds = true
    }
}
