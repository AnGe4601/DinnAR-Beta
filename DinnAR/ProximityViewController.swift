//
//  ProximityViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/21/25.
//

import UIKit
import SwiftUI

class ProximityViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var transportationTypeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceSlider.minimumValue = 0
        distanceSlider.maximumValue = 50
        distanceSlider.value = 10
        distanceSlider.isContinuous = true
        
        updateDistanceLabel()
        
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = UIColor(named: "ButtonColor")
        nextButton.layer.cornerRadius = 10
        nextButton.backgroundColor = UIColor(named: "ButtonColor")
    }
    
    @IBAction func changeDistanceValue(_ sender: UISlider) {
        let steppedValue = round(sender.value / 3) * 3
        sender.value = steppedValue
        updateDistanceLabel()
    }
    func updateDistanceLabel() {
        let value = Int(distanceSlider.value)
        if value <= 3 {
            transportationTypeLabel.text = "Walkable distance"
        } else if value <= 10 {
            transportationTypeLabel.text = "If your main transportation type is: Cycling/Bus/Scooter"
        } else {
            transportationTypeLabel.text = "If your main transportation type is: Car"
        }
        distanceLabel.text = "Resturant within the range of: \(value) miles"
    }
}
