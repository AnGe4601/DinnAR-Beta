//
//  VisitedManager.swift
//  DinnAR
//
//  Created by Swathi Rudravajjala on 12/7/25.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

class VisitedManager {

    static let shared = VisitedManager()
    private init() {}

    private(set) var visited: [Restaurant] = []

    // Reference to Firestore for the VisitedApp
    private var firestore: Firestore? {
        guard let app = FirebaseApp.app(name: "VisitedApp") else {
            print("VisitedApp not configured")
            return nil
        }
        return Firestore.firestore(app: app)
    }

    // MARK: - Fetch all visited restaurants
    func fetchVisited(completion: @escaping ([Restaurant]) -> Void) {
        firestore?.collection("visited").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching visited: \(error)")
                DispatchQueue.main.async { completion([]) }
                return
            }

            let fetched = snapshot?.documents.compactMap { doc -> Restaurant? in
                try? doc.data(as: Restaurant.self)
            } ?? []

            self.visited = fetched

            DispatchQueue.main.async {
                completion(fetched)
            }
        }
    }

    // MARK: - Check if restaurant is visited
    func isVisited(_ restaurant: Restaurant) -> Bool {
        return visited.contains(where: { $0.name == restaurant.name && $0.location == restaurant.location })
    }

    // MARK: - Toggle visited status
    func toggleVisited(_ restaurant: Restaurant, completion: @escaping (Error?) -> Void) {
        guard let firestore = firestore else {
            completion(nil)
            return
        }

        let docID = "\(restaurant.name)-\(restaurant.location)" // unique id per restaurant
        let docRef = firestore.collection("visited").document(docID)

        if isVisited(restaurant) {
            // Remove from Firestore
            docRef.delete { [weak self] error in
                if error == nil {
                    self?.visited.removeAll { $0.name == restaurant.name && $0.location == restaurant.location }
                }
                DispatchQueue.main.async { completion(error) }
            }
        } else {
            // Add to Firestore
            do {
                try docRef.setData(from: restaurant) { [weak self] error in
                    if error == nil {
                        self?.visited.append(restaurant)
                    }
                    DispatchQueue.main.async { completion(error) }
                }
            } catch {
                print("Error encoding restaurant: \(error)")
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
}
