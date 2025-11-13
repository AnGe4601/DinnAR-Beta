//
//  SettingViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/28/25.
//

import UIKit
import CoreLocation
import Contacts
import FirebaseAuth
import FirebaseFirestore

class SettingViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!

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
        case 2:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: false)
            } else {
                print("Could not load FriendsViewController – check Storyboard ID and class.")
            }
        case 3: break // Already on Settings
        default: break
        }
    }


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locSwitch: UISwitch!
    @IBOutlet weak var contactSwitch: UISwitch!

    let locationManager = CLLocationManager()
    let contacts = CNContactStore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 3 // Settings
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
            
        // Set unselected icon/text color
        segmentControl.tintColor = UIColor.gray
        fetchInfo()

        updateLocationSwitch()
        updateContactSwitch()
        locSwitch.addTarget(self, action: #selector(locationSwitchChanged), for: .valueChanged)
        contactSwitch.addTarget(self, action: #selector(contactSwitchChanged), for: .valueChanged)
        }
    private func fetchInfo() {
        guard let userid = Auth.auth().currentUser?.uid
        else {return}
        
        let db = Firestore.firestore()
        let user = db.collection("users").document(userid)
        user.getDocument { document, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            
            guard let doc = document, doc.exists,
                  let data = doc.data()
            else {
                return
            }
            
            let fullName = data["fullName"] as? String ?? "No Name"
//            let email = data["email"] as? String ?? "No Email"
//            let phone = data["phone"] as? String ?? "No Phone"
            
            DispatchQueue.main.async {
                self.nameLabel.text = "Hello,\(fullName)!"
            
            }
        }
    }
        private func updateLocationSwitch() {
            let status = CLLocationManager.authorizationStatus()
            locSwitch.isOn = (status == .authorizedAlways || status == .authorizedWhenInUse)
        }
        
        @objc private func locationSwitchChanged() {
            if locSwitch.isOn {
                locationManager.requestWhenInUseAuthorization()
            } else {
                openSettings()
            }
        }

        private func updateContactSwitch() {
            let status = CNContactStore.authorizationStatus(for: .contacts)
            contactSwitch.isOn = (status == .authorized)
        }
        
        @objc private func contactSwitchChanged() {
            if contactSwitch.isOn {
                contacts.requestAccess(for: .contacts) { granted, error in
                    DispatchQueue.main.async {
                        self.contactSwitch.isOn = granted
                        if !granted { self.openSettings() }
                    }
                }
            } else {
                openSettings()
            }
        }
        private func openSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString)
            else {
                return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }


