//
//  SettingViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/28/25.
//
//
//import UIKit
//import CoreLocation
//import Contacts
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseStorage
//
//class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    @IBOutlet weak var segmentControl: UISegmentedControl!
//
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false)
//        case 1:
//            let vc = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false)
//        case 2:
//            if let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
//                vc.modalPresentationStyle = .fullScreen
//                present(vc, animated: false)
//            } else {
//                print("Could not load FriendsViewController – check Storyboard ID and class.")
//            }
//        case 3: break // Already on Settings
//        default: break
//        }
//    }
//
//
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var locSwitch: UISwitch!
//    @IBOutlet weak var contactSwitch: UISwitch!
//
//    let locationManager = CLLocationManager()
//    let contacts = CNContactStore()
//        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        segmentControl.selectedSegmentIndex = 3 // Settings
//        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
//            
//        // Set unselected icon/text color
//        segmentControl.tintColor = UIColor.gray
//        fetchInfo()
//
//        updateLocationSwitch()
//        updateContactSwitch()
//        locSwitch.addTarget(self, action: #selector(locationSwitchChanged), for: .valueChanged)
//        contactSwitch.addTarget(self, action: #selector(contactSwitchChanged), for: .valueChanged)
//        setupProfileImageView()
//        loadProfileImage()
////        profileImageView.clipsToBounds = true
////        profileImageView.isUserInteractionEnabled = true
////        profileImageView.image = UIImage(systemName: "person.crop.square") // system placeholder
////        profileImageView.tintColor = .lightGray
////            
////        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
////        profileImageView.addGestureRecognizer(tapGesture)
////
////        loadProfileImage()
//        }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadProfileImage()
//    }
//    
//    private func fetchInfo() {
//        guard let userid = Auth.auth().currentUser?.uid
//        else {return}
//        
//        let db = Firestore.firestore()
//        let user = db.collection("users").document(userid)
//        user.getDocument { document, error in
//            if let error = error {
//                print("\(error.localizedDescription)")
//                return
//            }
//            
//            guard let doc = document, doc.exists,
//                  let data = doc.data()
//            else {
//                return
//            }
//            
//            let fullName = data["fullName"] as? String ?? "No Name"
////            let email = data["email"] as? String ?? "No Email"
////            let phone = data["phone"] as? String ?? "No Phone"
//            
//            DispatchQueue.main.async {
//                self.nameLabel.text = "Hello , \(fullName) !"
//            
//            }
//        }
//    }
//        private func updateLocationSwitch() {
//            let status = CLLocationManager.authorizationStatus()
//            locSwitch.isOn = (status == .authorizedAlways || status == .authorizedWhenInUse)
//        }
//        
//        @objc private func locationSwitchChanged() {
//            if locSwitch.isOn {
//                locationManager.requestWhenInUseAuthorization()
//            } else {
//                openSettings()
//            }
//        }
//
//        private func updateContactSwitch() {
//            let status = CNContactStore.authorizationStatus(for: .contacts)
//            contactSwitch.isOn = (status == .authorized)
//        }
//        
//        @objc private func contactSwitchChanged() {
//            if contactSwitch.isOn {
//                contacts.requestAccess(for: .contacts) { granted, error in
//                    DispatchQueue.main.async {
//                        self.contactSwitch.isOn = granted
//                        if !granted { self.openSettings() }
//                    }
//                }
//            } else {
//                openSettings()
//            }
//        }
//        private func openSettings() {
//            guard let url = URL(string: UIApplication.openSettingsURLString)
//            else {
//                return }
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:])
//            }
//        }
//    private func setupProfileImageView() {
//            profileImageView.layer.cornerRadius = 0 // square
//            profileImageView.clipsToBounds = true
//            profileImageView.contentMode = .scaleAspectFill
//            profileImageView.isUserInteractionEnabled = true
//            profileImageView.image = UIImage(systemName: "person.crop.square") // placeholder image
//            
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//            profileImageView.addGestureRecognizer(tapGesture)
//        }
//    @objc private func profileImageTapped() {
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.sourceType = .photoLibrary
//            picker.allowsEditing = true
//            present(picker, animated: true)
//        }
////    @objc private func profileImageTapped() {
////            let alert = UIAlertController(title: "Profile Picture", message: "Choose an option", preferredStyle: .actionSheet)
////            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera() }))
////            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in self.openPhotoLibrary() }))
////            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
////            present(alert, animated: true)
////        }
//        
////        private func openCamera() {
////            if UIImagePickerController.isSourceTypeAvailable(.camera) {
////                let picker = UIImagePickerController()
////                picker.sourceType = .camera
////                picker.delegate = self
////                picker.allowsEditing = true
////                present(picker, animated: true)
////            } else {
////                print("Camera not available")
////            }
////        }
////        
////        private func openPhotoLibrary() {
////            let picker = UIImagePickerController()
////            picker.sourceType = .photoLibrary
////            picker.delegate = self
////            picker.allowsEditing = true
////            present(picker, animated: true)
////        }
//        
////        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
////            picker.dismiss(animated: true)
////            if let editedImage = info[.editedImage] as? UIImage {
////                profileImageView.image = editedImage
////                uploadProfileImage(image: editedImage)
////            } else if let originalImage = info[.originalImage] as? UIImage {
////                profileImageView.image = originalImage
////                uploadProfileImage(image: originalImage)
////            }
////        }
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//          picker.dismiss(animated: true)
//          
//          guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
//          profileImageView.image = image
//          saveProfileImageToFirebase(image)
//      }
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//           picker.dismiss(animated: true)
//       }
//       
//       private func saveProfileImageToFirebase(_ image: UIImage) {
//           guard let uid = Auth.auth().currentUser?.uid,
//                 let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//           
//           let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
//           storageRef.putData(imageData, metadata: nil) { _, error in
//               if let error = error {
//                   print("Storage upload error: \(error.localizedDescription)")
//                   return
//               }
//               storageRef.downloadURL { url, error in
//                               if let url = url {
//                                   let db = Firestore.firestore()
//                                   db.collection("users").document(uid).updateData(["profileImageURL": url.absoluteString]) { err in
//                                       if let err = err {
//                                           print("Firestore update error: \(err.localizedDescription)")
//                                       } else {
//                                           print("Profile image saved successfully")
//                                       }
//                                   }
//                               }
//                                           }
//                                       }
//                                   }
////        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
////            picker.dismiss(animated: true)
////        }
////        
////        private func uploadProfileImage(image: UIImage) {
////            guard let uid = Auth.auth().currentUser?.uid else { return }
////            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
////            if let data = image.jpegData(compressionQuality: 0.8) {
////                storageRef.putData(data, metadata: nil) { _, error in
////                    if let error = error {
////                        print("Upload error: \(error.localizedDescription)")
////                        return
////                    }
////                    storageRef.downloadURL { url, _ in
////                        if let url = url {
////                            let db = Firestore.firestore()
////                            db.collection("users").document(uid).updateData(["profileImageUrl": url.absoluteString])
////                        }
////                    }
////                }
//
//private func loadProfileImage() {
//      guard let uid = Auth.auth().currentUser?.uid else { return }
//      let db = Firestore.firestore()
//      
//      db.collection("users").document(uid).getDocument { snapshot, error in
//          if let data = snapshot?.data(),
//             let urlString = data["profileImageURL"] as? String,
//             let url = URL(string: urlString) {
//              URLSession.shared.dataTask(with: url) { data, _, _ in
//                  if let data = data, let image = UIImage(data: data) {
//                      DispatchQueue.main.async {
//                          self.profileImageView.image = image
//                      }
//                  }
//              }.resume()
//          }
//      }
//  }
//  
//        
////    private func loadProfileImage() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////        let db = Firestore.firestore()
////        db.collection("users").document(uid).getDocument { doc, _ in
////            if let data = doc?.data(), let urlStr = data["profileImageUrl"] as? String, let url = URL(string: urlStr) {
////                DispatchQueue.main.async {
////                    URLSession.shared.dataTask(with: url) { data, _, _ in
////                        if let data = data {
////                            DispatchQueue.main.async {
////                                self.profileImageView.image = UIImage(data: data)
////                            }
////                        }
////                    }.resume()
////                }
////            }
////        }
////    }
//    @IBAction func deleteAccountPressed(_ sender: UIButton) {
//            let alert = UIAlertController(
//                title: "Delete Account",
//                message: "This action cannot be undone. Do you want to proceed?",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//                self.deleteAccount()
//            }))
//            
//            present(alert, animated: true)
//        }
//        
//        
//        private func deleteAccount() {
//            guard let user = Auth.auth().currentUser else { return }
//            let uid = user.uid
//            let db = Firestore.firestore()
//            
////            startLoading()
//            
//            // Step 1: Delete Firestore Data
//            db.collection("users").document(uid).delete { firestoreError in
//                if let firestoreError = firestoreError {
//                    print("Firestore delete error: \(firestoreError.localizedDescription)")
////                    self.stopLoading()
//                    return
//                }
//                
//                // Step 2: Delete Auth User
//                user.delete { authError in
////                    self.stopLoading()
//                    
//                    if let authError = authError as NSError? {
//                        if authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
//                            self.showReauthAlert()
//                        } else {
//                            print("Auth delete error: \(authError.localizedDescription)")
//                        }
//                        return
//                    }
//                    
//                    // Success → Go to login
//                    self.presentLoginScreen()
//                }
//            }
//        }
//    @IBAction func logoutPressed(_ sender: UIButton) {
//        let alert = UIAlertController(
//            title: "Logout",
//            message: "Are you sure you want to log out?",
//            preferredStyle: .alert
//        )
//        
//        // Cancel button
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // Confirm logout
//        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
//            self.performLogout()
//        }))
//        
//        present(alert, animated: true)
//    }
//
//    private func performLogout() {
//        do {
//            try Auth.auth().signOut()
//            presentLoginScreen()
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//    @IBAction func editPreferencesPressed(_ sender: UIButton) {
//            let alert = UIAlertController(
//                title: "Edit Preferences",
//                message: "Are you sure you want to edit your preferences?",
//                preferredStyle: .alert
//            )
//            
//            // Cancel button
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            
//            // Confirm button
//            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//                // Instantiate the existing ViewController
//                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
//                    
//                    // Use navigation controller if exists
//                    if let nav = self.navigationController {
//                        nav.pushViewController(vc, animated: true)
//                    } else {
//                        vc.modalPresentationStyle = .fullScreen
//                        self.present(vc, animated: true)
//                    }
//                    
//                } else {
//                    print("Could not load ViewController – check Storyboard ID.")
//                }
//            }))
//            
//            present(alert, animated: true)
//        }
//
//
//
//    private func openPreferencesScreen() {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            print("Could not load PreferencesViewController – check Storyboard ID and class.")
//        }
//    }
//
////    private func openPreferencesScreen() {
////        if let vc = storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as? PreferencesViewController {
////            vc.modalPresentationStyle = .fullScreen
////            present(vc, animated: true)
////        } else {
////            print("Could not load PreferencesViewController – check Storyboard ID and class.")
////        }
////    }
//
//
//
//        
//        
//        private func showReauthAlert() {
//            let alert = UIAlertController(
//                title: "Re-login Required",
//                message: "Please sign in again to delete your account.",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                self.presentLoginScreen()
//            }))
//            
//            present(alert, animated: true)
//        }
//        
//        
//        
//    private func presentLoginScreen() {
//        DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//
//            // Wrap login screen in a new navigation controller
//            let nav = UINavigationController(rootViewController: loginVC)
//            nav.navigationBar.isHidden = true   // optional
//            
//            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let window = scene.windows.first {
//
//                window.rootViewController = nav
//                window.makeKeyAndVisible()
//            }
//
//            print("Successfully reset root VC to Login inside new NavController.")
//        }
//    }
//
//        }
//        
//   
import UIKit
import CoreLocation
import Contacts
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locSwitch: UISwitch!
    @IBOutlet weak var contactSwitch: UISwitch!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let contacts = CNContactStore()
    private let profileImageCacheKey = "cachedProfileImage"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 3 // Settings
        segmentControl.selectedSegmentTintColor = UIColor.burntOrange
        segmentControl.tintColor = UIColor.gray
        
        setupProfileImageView()
        fetchInfo()
        updateLocationSwitch()
        updateContactSwitch()
        
        locSwitch.addTarget(self, action: #selector(locationSwitchChanged), for: .valueChanged)
        contactSwitch.addTarget(self, action: #selector(contactSwitchChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileImage()
    }
    
    // MARK: - Setup
    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = 0 // square
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.image = UIImage(systemName: "person.crop.square") // placeholder
        profileImageView.tintColor = .lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Profile Image Actions
    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        
        // Update image immediately
        profileImageView.image = image
        
        // Save locally for instant load
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: profileImageCacheKey)
        }
        
        // Save to Firebase
        saveProfileImageToFirebase(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveProfileImageToFirebase(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Storage upload error: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url {
                    let db = Firestore.firestore()
                    db.collection("users").document(uid).updateData(["profileImageURL": url.absoluteString]) { err in
                        if let err = err {
                            print("Firestore update error: \(err.localizedDescription)")
                        } else {
                            print("Profile image saved successfully")
                        }
                    }
                }
            }
        }
    }
    
    private func loadProfileImage() {
            // First check local cache
            if let data = UserDefaults.standard.data(forKey: profileImageCacheKey), let image = UIImage(data: data) {
                profileImageView.image = image
                return
            }

            // If no cache, fetch from Firestore
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()

            db.collection("users").document(uid).getDocument { snapshot, _ in
                guard let data = snapshot?.data() else { return }

                if let urlString = data["profileImageURL"] as? String, let url = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profileImageView.image = image
                                
                                // Save locally for cache
                                UserDefaults.standard.set(data, forKey: self.profileImageCacheKey)
                            }
                        }
                    }.resume()
                }
            }
        }
    
    // MARK: - Segment Control
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
        case 3: break // Settings
        default: break
        }
    }
    
    // MARK: - User Info
    private func fetchInfo() {
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userid).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let doc = document, doc.exists, let data = doc.data() else { return }
            let fullName = data["fullName"] as? String ?? "No Name"
            
            DispatchQueue.main.async {
                self.nameLabel.text = "Hello, \(fullName)!"
            }
        }
    }
    
    // MARK: - Switches
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
            contacts.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    self.contactSwitch.isOn = granted
                    if !granted { self.openSettings() }
                }
            }
        } else {
            openSettings()
        }
    }
    
    
    @IBAction func editPreferencesPressed(_ sender: Any) {
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
    @IBAction func logoutPressed(_ sender: Any) {
    
//    @IBAction func logoutPressed(_ sender: UIButton) {
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
    //        @IBAction func editPreferencesPressed(_ sender: UIButton) {
    //                let alert = UIAlertController(
    //                    title: "Edit Preferences",
    //                    message: "Are you sure you want to edit your preferences?",
    //                    preferredStyle: .alert
    //                )
    //
    //                // Cancel button
    //                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    //
    //                // Confirm button
    //                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
    //                    // Instantiate the existing ViewController
    //                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
    //
    //                        // Use navigation controller if exists
    //                        if let nav = self.navigationController {
    //                            nav.pushViewController(vc, animated: true)
    //                        } else {
    //                            vc.modalPresentationStyle = .fullScreen
    //                            self.present(vc, animated: true)
    //                        }
    //
    //                    } else {
    //                        print("Could not load ViewController – check Storyboard ID.")
    //                    }
    //                }))
    //
    //                present(alert, animated: true)
    //            }
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
    
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}

