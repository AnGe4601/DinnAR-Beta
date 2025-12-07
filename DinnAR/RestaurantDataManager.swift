//
//  RestaurantDataManager.swift
//  DinnAR
//
//  Created by Angela Liu on 12/6/25.
//

import Foundation

class ResturantDataManager {
    static let shared = ResturantDataManager()

    static let didUpdateRestaurants = Notification.Name("didUpdateRestaurants")

    var fetchedRestaurants: [Restaurant] {
        didSet {
            print("Posting notification — didUpdateRestaurants")
            NotificationCenter.default.post(
                name: ResturantDataManager.didUpdateRestaurants,
                object: nil
            )
        }
    }

    private init() {
        self.fetchedRestaurants = []
    }
}

