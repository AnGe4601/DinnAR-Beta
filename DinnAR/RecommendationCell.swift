import UIKit

class RecommendationCell: UITableViewCell {
    
    // individual cell labels
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        restaurantImageView.layer.cornerRadius = 8
        restaurantImageView.clipsToBounds = true
    }

    func configure(with restaurant: Restaurant) {
        restaurantImageView.image = UIImage(named: restaurant.imageName)
        nameLabel.text = restaurant.name
        cuisineLabel.text = restaurant.cuisine
        starsLabel.text = restaurant.stars
    }
}
