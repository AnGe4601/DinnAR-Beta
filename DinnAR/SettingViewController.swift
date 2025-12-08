import UIKit
import CoreLocation
import Contacts
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Photos


class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locSwitch: UISwitch!
    @IBOutlet weak var contactSwitch: UISwitch!
    
    let locationManager = CLLocationManager()
    let contacts = CNContactStore()
    private var profileImageCacheKey: String {
        return "cachedProfileImage_\(Auth.auth().currentUser?.uid ?? "unknown")"
    }
    
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
        updateLocationSwitch()
        updateContactSwitch()
        
        loadProfileImage()
    }
    
    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = 0
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.image = UIImage(systemName: "person.crop.square") // placeholder
        profileImageView.tintColor = .lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }
 
    @objc private func profileImageTapped() {
        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.presentImagePicker()
                    } else {
                        self.openSettings()
                    }
                }
            }

        case .authorized, .limited:
            presentImagePicker()

        case .denied, .restricted:
            openSettings()

        default:
            break
        }
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        profileImageView.image = image
        uploadLabel.isHidden = true
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: profileImageCacheKey)
        }
        
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
                uploadLabel.isHidden = true
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()

            db.collection("users").document(uid).getDocument { snapshot, _ in
                guard let data = snapshot?.data() else { return }

                if let urlString = data["profileImageURL"] as? String, let url = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profileImageView.image = image
                                self.uploadLabel.isHidden =  true
                                
                                UserDefaults.standard.set(data, forKey: self.profileImageCacheKey)
                            }
                        }
                    }.resume()
                }
            }
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
    
    private func updateLocationSwitch() {
//        let status = CLLocationManager.authorizationStatus()
//        locSwitch.isOn = (status == .authorizedAlways || status == .authorizedWhenInUse)
        let status = locationManager.authorizationStatus

        locSwitch.isOn = (status == .authorizedAlways || status == .authorizedWhenInUse)
       }
    
    
    @objc private func locationSwitchChanged() {
//        if locSwitch.isOn {
//            locationManager.requestWhenInUseAuthorization()
//        } else {
//            openSettings()
//        }
//    }
        if locSwitch.isOn {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Switch should jump back immediately (because you can’t revoke permission here)
            locSwitch.isOn = (locationManager.authorizationStatus == .authorizedAlways ||
                              locationManager.authorizationStatus == .authorizedWhenInUse)

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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
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
//            print("xx")
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
        
        
        db.collection("users").document(uid).delete { firestoreError in
            if let firestoreError = firestoreError {
                print("Firestore delete error: \(firestoreError.localizedDescription)")
                return
            }
            
            user.delete { authError in
                
                if let authError = authError as NSError? {
                    if authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        self.showReauthAlert()
                    } else {
                        print("Auth delete error: \(authError.localizedDescription)")
                    }
                    return
                }
                
                self.presentLoginScreen()
            }
        }
    }
    @IBAction func logoutPressed(_ sender: Any) {
    
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
 
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}




