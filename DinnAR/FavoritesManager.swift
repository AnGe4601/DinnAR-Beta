//
//  FavoritesManager.swift
//  DinnAR
//
//  Created by Swathi Rudravajjala on 11/11/25.
//

import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private init() {}
    
    private var favoriteRestaurants: [Restaurant] = []  // changed name for clarity
    
    // MARK: - Accessors
    var favorites: [Restaurant] {
        return favoriteRestaurants
    }
    
    func isFavorite(_ restaurant: Restaurant) -> Bool {
        favoriteRestaurants.contains(where: { $0.name == restaurant.name })
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        if isFavorite(restaurant) {
            favoriteRestaurants.removeAll(where: { $0.name == restaurant.name })
        } else {
            favoriteRestaurants.append(restaurant)
        }
    }
    
    func remove(_ restaurant: Restaurant) {
        favoriteRestaurants.removeAll(where: { $0.name == restaurant.name })
    }
}
