//
//  FavoritesManager.swift
//  DinnAR
//
//  Created by Swathi Rudravajjala on 11/11/25.
//

import Foundation
import FirebaseFirestore
import Firebase

class FavoritesManager {
    
    static let shared = FavoritesManager()
    private init() {}
    
    private var favoriteRestaurants: [Restaurant] = []
    
    private var firestore: Firestore? {
        guard let app = FirebaseApp.app(name: "VisitedApp") else { return nil }
        return Firestore.firestore(app: app)
    }
    
    func allFavorites() -> [Restaurant] {
        return favoriteRestaurants
    }
    
    func isFavorite(_ restaurant: Restaurant) -> Bool {
        return favoriteRestaurants.contains(where: { $0.name == restaurant.name && $0.location == restaurant.location })
    }
    
    func toggleFavorite(_ restaurant: Restaurant, completion: ((Error?) -> Void)? = nil) {
        guard let firestore = firestore else {
            completion?(NSError(domain: "FavoritesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Firestore not configured"]))
            return
        }
        
        let docID = "\(restaurant.name)_\(restaurant.location)"
        
        if isFavorite(restaurant) {
            favoriteRestaurants.removeAll(where: { $0.name == restaurant.name && $0.location == restaurant.location })
            firestore.collection("favorites").document(docID).delete { error in
                completion?(error)
            }
        } else {
            favoriteRestaurants.append(restaurant)
            let data: [String: Any] = [
                "name": restaurant.name,
                "location": restaurant.location,
                "cuisine": restaurant.cuisine ?? ""
            ]
            firestore.collection("favorites").document(docID).setData(data) { error in
                completion?(error)
            }
        }
    }
    
    func fetchFavorites(completion: @escaping ([Restaurant]) -> Void) {
        guard let firestore = firestore else {
            completion([])
            return
        }
        
        firestore.collection("favorites").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching favorites: \(error)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            // Only populate the minimal fields needed
            let restaurants = documents.compactMap { doc -> Restaurant? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let location = data["location"] as? String else { return nil }
                let cuisine = data["cuisine"] as? String
                
                // Provide default values for all required fields
                return Restaurant(
                    name: name,
                    cuisine: cuisine,
                    stars: "",
                    imageURL: nil,
                    reviews: "",
                    priceLevel: "",
                    distance: "",
                    location: location,
                    lat: 0,
                    long: 0
                )
            }
            
            self.favoriteRestaurants = restaurants
            completion(restaurants)
        }
    }
}
