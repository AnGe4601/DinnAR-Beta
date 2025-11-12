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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locSwitch: UISwitch!
    @IBOutlet weak var contactSwitch: UISwitch!

    let locationManager = CLLocationManager()
    let contacts = CNContactStore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
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


