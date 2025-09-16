//
//  SkillBallrApp.swift
//  SkillBallr
//
//  Created by Greg Miller on 9/16/25.
//

import SwiftUI

@main
struct SkillBallrApp: App {
    let persistenceController = PersistenceController.shared
    
    // MARK: - App State Management
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(authManager)
                .environmentObject(subscriptionManager)
                .onAppear {
                    configureApp()
                }
        }
    }
    
    // MARK: - App Configuration
    private func configureApp() {
        // Configure Firebase
        configureFirebase()
        
        // Configure Analytics
        configureAnalytics()
        
        // Configure Notifications
        configureNotifications()
        
        // Initialize app state
        appState.initialize()
    }
    
    private func configureFirebase() {
        // TODO: Configure Firebase when SDK is added
        print("Firebase configuration will be added in Phase 2")
    }
    
    private func configureAnalytics() {
        // TODO: Configure Analytics when SDK is added
        print("Analytics configuration will be added in Phase 2")
    }
    
    private func configureNotifications() {
        // TODO: Configure Push Notifications
        print("Push notifications will be configured in Phase 3")
    }
}
