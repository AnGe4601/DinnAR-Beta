import CoreLocation
import Contacts

class PermissionManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = PermissionManager()
    private let locationManager = CLLocationManager()
    private let contactStore = CNContactStore()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func requestContactsPermission(completion: ((Bool) -> Void)? = nil) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            contactStore.requestAccess(for: .contacts) { granted, complete in
                completion?(granted)
            }
        } else {
            completion?(status == .authorized)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}

