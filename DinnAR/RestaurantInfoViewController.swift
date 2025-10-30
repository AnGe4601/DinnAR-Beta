//
//  RestaurantInfoViewController.swift
//  DinnAR
//
//  Created by Srinidhi P on 10/21/25.
//

import UIKit

class RestaurantInfoViewController: UIViewController {
    
    var restaurant: Restaurant?
    
    // restaurant labels
    @IBOutlet weak var nameLabel: UILabel!
    
    // visited button
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBAction func infoSegmentControl(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = restaurant?.name
        
        if let urlString = restaurant?.imageURL,
           let url = URL(string: urlString),
           urlString.starts(with: "http") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data, error == nil,
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.restaurantImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
