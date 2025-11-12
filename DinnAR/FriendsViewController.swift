//  FriendsViewController.swift
//  DinnAR
//  Created by Swathi Rudravajjala on 11/11/25.

import UIKit

class FriendsViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 2 // Friends
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
            
        // Set unselected icon/text color
        segmentControl.tintColor = UIColor.gray
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        case 2: break // Already on Friends
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        default: break
        }
    }
}
