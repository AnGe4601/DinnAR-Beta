//
//  UserPreferencesManager.swift
//  DinnAR
//
//  Created by Srinidhi P on 12/6/25.
//
import Foundation

class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let restaurantTypes = "selectedRestaurantTypes"
        static let cuisineTypes = "selectedCuisineTypes"
        static let dietaryRestrictions = "selectedDietaryRestrictions"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Save Preferences
    
    func saveRestaurantTypes(_ types: [String]) {
        userDefaults.set(types, forKey: Keys.restaurantTypes)
    }
    
    func saveCuisineTypes(_ types: [String]) {
        userDefaults.set(types, forKey: Keys.cuisineTypes)
    }
    
    func saveDietaryRestrictions(_ restrictions: [String]) {
        userDefaults.set(restrictions, forKey: Keys.dietaryRestrictions)
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        userDefaults.set(completed, forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - Get Preferences
    
    func getRestaurantTypes() -> [String] {
        return userDefaults.stringArray(forKey: Keys.restaurantTypes) ?? []
    }
    
    func getCuisineTypes() -> [String] {
        return userDefaults.stringArray(forKey: Keys.cuisineTypes) ?? []
    }
    
    func getDietaryRestrictions() -> [String] {
        return userDefaults.stringArray(forKey: Keys.dietaryRestrictions) ?? []
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - Clear Preferences
    
    func clearAllPreferences() {
        userDefaults.removeObject(forKey: Keys.restaurantTypes)
        userDefaults.removeObject(forKey: Keys.cuisineTypes)
        userDefaults.removeObject(forKey: Keys.dietaryRestrictions)
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
