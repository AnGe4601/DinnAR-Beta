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

    private var firestore: Firestore? {
        guard let app = FirebaseApp.app(name: "VisitedApp") else {
            print("VisitedApp not configured")
            return nil
        }
        return Firestore.firestore(app: app)
    }

    // MARK: - Fetch all visited
    func fetchVisited(completion: @escaping ([Restaurant]) -> Void) {
        firestore?.collection("visited").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching visited: \(error)")
                completion([]); return
            }

            let fetched = snapshot?.documents.compactMap { doc -> Restaurant? in
                try? doc.data(as: Restaurant.self)
            } ?? []

            self.visited = fetched
            completion(fetched)
        }
    }

    // MARK: - Check if visited
    func isVisited(_ restaurant: Restaurant) -> Bool {
        return visited.contains {
            $0.name == restaurant.name && $0.location == restaurant.location
        }
    }

    // MARK: - Toggle visited status
    func toggleVisited(_ restaurant: Restaurant, completion: @escaping (Error?) -> Void) {
        guard let firestore else { completion(nil); return }

        let docID = "\(restaurant.name)-\(restaurant.location)"
        let docRef = firestore.collection("visited").document(docID)

        if isVisited(restaurant) {
            // Remove
            docRef.delete { error in
                if error == nil {
                    self.visited.removeAll {
                        $0.name == restaurant.name && $0.location == restaurant.location
                    }
                }
                completion(error)
            }
        } else {
            // Add
            do {
                try docRef.setData(from: restaurant) { error in
                    if error == nil {
                        self.visited.append(restaurant)
                    }
                    completion(error)
                }
            } catch {
                print("Encoding error: \(error)")
                completion(error)
            }
        }
    }
}
