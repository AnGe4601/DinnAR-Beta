//
//  ViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/14/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 10
        nextButton.backgroundColor = UIColor(named: "ButtonColor")
        likeLabel.font = UIFont(name: "DMSerifText-Italic", size: 40)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToCuisineVCSI", sender: self)
    }
    
}

