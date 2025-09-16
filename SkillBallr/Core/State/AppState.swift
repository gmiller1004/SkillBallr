import Foundation
import Combine
import SwiftUI

/// Main app state manager for SkillBallr
@MainActor
class AppState: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var currentUser: UserProfile?
    @Published var hasCompletedOnboarding = false
    @Published var selectedTab: TabItem = .player
    @Published var currentUserProfile: UserProfile? // For compatibility with onboarding
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Tab Items
    enum TabItem: String, CaseIterable, Identifiable {
        case player = "player"
        case coach = "coach"
        case profile = "profile"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .player: return "Player"
            case .coach: return "Coach"
            case .profile: return "Profile"
            }
        }
        
        var icon: String {
            switch self {
            case .player: return "figure.walk.diamond.fill"
            case .coach: return "person.3.fill"
            case .profile: return "person.circle.fill"
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        loadInitialState()
    }
    
    // MARK: - Public Methods
    func initialize() {
        isLoading = true
        
        // Load user profile
        loadUserProfile()
        
        // Check onboarding status
        checkOnboardingStatus()
        
        // Initialize other managers
        Task {
            await performInitialization()
        }
    }
    
    func setCurrentUser(_ user: UserProfile) {
        currentUser = user
        currentUserProfile = user // Keep both in sync
        saveUserProfile(user)
        
        // Update tab selection based on user role
        if user.role == .coach {
            selectedTab = .coach
        } else {
            selectedTab = .player
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: AppConfiguration.UserDefaultsKey.hasCompletedOnboarding.rawValue)
    }
    
    func signOut() {
        currentUser = nil
        hasCompletedOnboarding = false
        selectedTab = .player
        
        // Clear user defaults
        userDefaults.removeObject(forKey: AppConfiguration.UserDefaultsKey.userProfile.rawValue)
        userDefaults.removeObject(forKey: AppConfiguration.UserDefaultsKey.hasCompletedOnboarding.rawValue)
        
        // TODO: Clear Core Data cache
        // TODO: Sign out from Firebase
    }
    
    func updateSubscriptionTier(_ tier: SubscriptionTier) {
        guard var user = currentUser else { return }
        
        user.subscriptionTier = tier
        user.updatedAt = Date()
        
        setCurrentUser(user)
        saveSubscriptionTier(tier)
    }
    
    // MARK: - Private Methods
    private func loadInitialState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: AppConfiguration.UserDefaultsKey.hasCompletedOnboarding.rawValue)
        
        if let savedTier = userDefaults.string(forKey: AppConfiguration.UserDefaultsKey.subscriptionTier.rawValue),
           let tier = SubscriptionTier(rawValue: savedTier) {
            // Load subscription tier if available
        }
    }
    
    private func loadUserProfile() {
        if let userData = userDefaults.data(forKey: AppConfiguration.UserDefaultsKey.userProfile.rawValue),
           let user = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            currentUser = user
        }
    }
    
    private func saveUserProfile(_ user: UserProfile) {
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: AppConfiguration.UserDefaultsKey.userProfile.rawValue)
        }
    }
    
    private func saveSubscriptionTier(_ tier: SubscriptionTier) {
        userDefaults.set(tier.rawValue, forKey: AppConfiguration.UserDefaultsKey.subscriptionTier.rawValue)
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = userDefaults.bool(forKey: AppConfiguration.UserDefaultsKey.hasCompletedOnboarding.rawValue)
    }
    
    private func performInitialization() async {
        // Simulate initialization delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // TODO: Initialize other services
        // - Network manager
        // - Data manager
        // - Analytics
        // - Notifications
        
        await MainActor.run {
            isLoading = false
            isInitialized = true
        }
    }
}

// MARK: - Computed Properties
extension AppState {
    var isUserLoggedIn: Bool {
        return currentUser != nil
    }
    
    var userRole: UserRole? {
        return currentUser?.role
    }
    
    var subscriptionTier: SubscriptionTier {
        return currentUser?.subscriptionTier ?? .free
    }
    
    var canAccessPremiumFeatures: Bool {
        return subscriptionTier != .free
    }
    
    var shouldShowOnboarding: Bool {
        return !hasCompletedOnboarding
    }
}
