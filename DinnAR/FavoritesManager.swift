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
        guard let app = FirebaseApp.app(name: "VisitedApp") else {
            print("VisitedApp not configured")
            return nil
        }
        return Firestore.firestore(app: app)
    }

    // MARK: - PUBLIC API
    func allFavorites() -> [Restaurant] {
        return favoriteRestaurants
    }

    func isFavorite(_ restaurant: Restaurant) -> Bool {
        return favoriteRestaurants.contains {
            $0.name == restaurant.name && $0.location == restaurant.location
        }
    }

    func toggleFavorite(_ restaurant: Restaurant, completion: ((Error?) -> Void)? = nil) {
        guard let firestore else {
            completion?(NSError(domain: "FavoritesManager",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Firestore not configured"]))
            return
        }

        // Generate a unique stable ID for each restaurant
        let docID = "\(restaurant.name)-\(restaurant.location)"
        let docRef = firestore.collection("favorites").document(docID)

        if isFavorite(restaurant) {
            // REMOVE from Firestore
            docRef.delete { error in
                if error == nil {
                    self.favoriteRestaurants.removeAll {
                        $0.name == restaurant.name && $0.location == restaurant.location
                    }
                }
                completion?(error)
            }
        } else {
            // ADD to Firestore
            do {
                try docRef.setData(from: restaurant) { error in
                    if error == nil {
                        self.favoriteRestaurants.append(restaurant)
                    }
                    completion?(error)
                }
            } catch {
                print("Encoding error: \(error)")
                completion?(error)
            }
        }
    }

    func fetchFavorites(completion: @escaping ([Restaurant]) -> Void) {
        guard let firestore else {
            completion([]); return
        }

        firestore.collection("favorites").getDocuments { snapshot, error in
            if let error {
                print("Error fetching favorites: \(error)")
                completion([]); return
            }

            let fetched = snapshot?.documents.compactMap { doc -> Restaurant? in
                try? doc.data(as: Restaurant.self)
            } ?? []

            self.favoriteRestaurants = fetched
            completion(fetched)
        }
    }
}
