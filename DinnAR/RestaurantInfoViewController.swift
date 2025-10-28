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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var reservationButton: UIButton!
    
    // visited button
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    // hamburger menu - yet to implement
    @IBAction func hamburgerMenu(_ sender: Any) {
    }
    
    @IBAction func infoSegmentControl(_ sender: Any) {
        // Hide all views
        dealsView.isHidden = true
        menuView.isHidden = true
        reviewView.isHidden = true
        waittimeView.isHidden = true
        
        // Show the selected one
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            dealsView.isHidden = false
        case 1:
            menuView.isHidden = false
        case 2:
            reviewView.isHidden = false
        case 3:
            waittimeView.isHidden = false
        default:
            break
        }
    }
    
    @IBOutlet weak var dealsView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var waittimeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set name and image from the selected restaurant
        nameLabel.text = restaurant?.name
        
        if let imageName = restaurant?.imageName {
            restaurantImageView.image = UIImage(named: imageName)
        } else {
            restaurantImageView.image = UIImage(named: "placeholder") // backup image
        }
    }
}
