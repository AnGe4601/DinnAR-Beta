//
//  UserPreferencesManager.swift
//  DinnAR
//
//  Created by Srinidhi P on 12/6/25.
//
import Foundation
import FirebaseAuth

class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static func restaurantTypes(for userId: String) -> String {
            return "\(userId)_restaurantTypes"
        }
        static func cuisineTypes(for userId: String) -> String {
            return "\(userId)_cuisineTypes"
        }
        static func dietaryRestrictions(for userId: String) -> String {
            return "\(userId)_dietaryRestrictions"
        }
        static func hasCompletedOnboarding(for userId: String) -> String {
            return "\(userId)_onboardingComplete"
        }
    }
    
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Save Preferences
    
    func saveRestaurantTypes(_ types: [String]) {
        guard let userId = getCurrentUserId() else { return }
        userDefaults.set(types, forKey: Keys.restaurantTypes(for: userId))
    }
    
    func saveCuisineTypes(_ types: [String]) {
        guard let userId = getCurrentUserId() else { return }
        userDefaults.set(types, forKey: Keys.cuisineTypes(for: userId))
    }
    
    func saveDietaryRestrictions(_ restrictions: [String]) {
        guard let userId = getCurrentUserId() else { return }
        userDefaults.set(restrictions, forKey: Keys.dietaryRestrictions(for: userId))
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        guard let userId = getCurrentUserId() else { return }
        userDefaults.set(completed, forKey: Keys.hasCompletedOnboarding(for: userId))
    }
    
    // MARK: - Get Preferences
    
    func getRestaurantTypes() -> [String] {
        guard let userId = getCurrentUserId() else { return [] }
        return userDefaults.stringArray(forKey: Keys.restaurantTypes(for: userId)) ?? []
    }
    
    func getCuisineTypes() -> [String] {
        guard let userId = getCurrentUserId() else { return [] }
        return userDefaults.stringArray(forKey: Keys.cuisineTypes(for: userId)) ?? []
    }
    
    func getDietaryRestrictions() -> [String] {
        guard let userId = getCurrentUserId() else { return [] }
        return userDefaults.stringArray(forKey: Keys.dietaryRestrictions(for: userId)) ?? []
    }
    
    func hasCompletedOnboarding() -> Bool {
        guard let userId = getCurrentUserId() else { return false }
        return userDefaults.bool(forKey: Keys.hasCompletedOnboarding(for: userId))
    }
    
    // MARK: - Clear Preferences
    
    func clearAllPreferences() {
        guard let userId = getCurrentUserId() else { return }
        userDefaults.removeObject(forKey: Keys.restaurantTypes(for: userId))
        userDefaults.removeObject(forKey: Keys.cuisineTypes(for: userId))
        userDefaults.removeObject(forKey: Keys.dietaryRestrictions(for: userId))
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding(for: userId))
    }
}
