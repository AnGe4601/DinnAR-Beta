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
                self.nameLabel.text = "Hello , \(fullName) !"
            
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
    @IBAction func deleteAccountPressed(_ sender: UIButton) {
            let alert = UIAlertController(
                title: "Delete Account",
                message: "This action cannot be undone. Do you want to proceed?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteAccount()
            }))
            
            present(alert, animated: true)
        }
        
        
        private func deleteAccount() {
            guard let user = Auth.auth().currentUser else { return }
            let uid = user.uid
            let db = Firestore.firestore()
            
//            startLoading()
            
            // Step 1: Delete Firestore Data
            db.collection("users").document(uid).delete { firestoreError in
                if let firestoreError = firestoreError {
                    print("Firestore delete error: \(firestoreError.localizedDescription)")
//                    self.stopLoading()
                    return
                }
                
                // Step 2: Delete Auth User
                user.delete { authError in
//                    self.stopLoading()
                    
                    if let authError = authError as NSError? {
                        if authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                            self.showReauthAlert()
                        } else {
                            print("Auth delete error: \(authError.localizedDescription)")
                        }
                        return
                    }
                    
                    // Success → Go to login
                    self.presentLoginScreen()
                }
            }
        }
    @IBAction func logoutPressed(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Confirm logout
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    @IBAction func editPreferencesPressed(_ sender: UIButton) {
            let alert = UIAlertController(
                title: "Edit Preferences",
                message: "Are you sure you want to edit your preferences?",
                preferredStyle: .alert
            )
            
            // Cancel button
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // Confirm button
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                // Instantiate the existing ViewController
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
                    
                    // Use navigation controller if exists
                    if let nav = self.navigationController {
                        nav.pushViewController(vc, animated: true)
                    } else {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                    
                } else {
                    print("Could not load ViewController – check Storyboard ID.")
                }
            }))
            
            present(alert, animated: true)
        }



    private func openPreferencesScreen() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("Could not load PreferencesViewController – check Storyboard ID and class.")
        }
    }

//    private func openPreferencesScreen() {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as? PreferencesViewController {
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true)
//        } else {
//            print("Could not load PreferencesViewController – check Storyboard ID and class.")
//        }
//    }



        
        
        private func showReauthAlert() {
            let alert = UIAlertController(
                title: "Re-login Required",
                message: "Please sign in again to delete your account.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.presentLoginScreen()
            }))
            
            present(alert, animated: true)
        }
        
        
        
    private func presentLoginScreen() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

            // Wrap login screen in a new navigation controller
            let nav = UINavigationController(rootViewController: loginVC)
            nav.navigationBar.isHidden = true   // optional
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {

                window.rootViewController = nav
                window.makeKeyAndVisible()
            }

            print("Successfully reset root VC to Login inside new NavController.")
        }
    }

        }
        
   
