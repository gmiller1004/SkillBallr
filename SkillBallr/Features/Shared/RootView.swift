import SwiftUI

/// Root view that handles the main app navigation and state
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    var body: some View {
        Group {
            if appState.isLoading {
                SkillBallrLoadingView()
            } else if !appState.isInitialized {
                SkillBallrLoadingView()
            } else if !authManager.isAuthenticated {
                // Show onboarding for new users, sign-in for returning users
                if appState.hasCompletedOnboarding {
                    PasswordlessAuthenticationView()
                } else {
                    OnboardingView()
                }
            } else if appState.shouldShowOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isLoading)
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: appState.shouldShowOnboarding)
    }
}

/// Main tab view for authenticated users
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            PlayerView()
                .tabItem {
                    Image(systemName: AppState.TabItem.player.icon)
                    Text(AppState.TabItem.player.displayName)
                }
                .tag(AppState.TabItem.player)
            
            CoachView()
                .tabItem {
                    Image(systemName: AppState.TabItem.coach.icon)
                    Text(AppState.TabItem.coach.displayName)
                }
                .tag(AppState.TabItem.coach)
            
            ProfileView()
                .tabItem {
                    Image(systemName: AppState.TabItem.profile.icon)
                    Text(AppState.TabItem.profile.displayName)
                }
                .tag(AppState.TabItem.profile)
        }
        .accentColor(SkillBallrColors.skillOrange)
        .onAppear {
            // Example: Sign out button for testing
            print("MainTabView appeared. Current user: \(appState.currentUser?.firstName ?? "N/A")")
        }
    }
}


// MARK: - Placeholder Views
struct PlayerView: View {
    var body: some View {
        VStack {
            Text("Player Dashboard")
                .font(.skillBallr(.extraLargeTitle))
                .foregroundColor(.white)
            Text("Coming soon...")
                .font(.skillBallr(.body))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkillBallrColors.background.ignoresSafeArea())
    }
}

struct CoachView: View {
    var body: some View {
        VStack {
            Text("Coach Dashboard")
                .font(.skillBallr(.extraLargeTitle))
                .foregroundColor(.white)
            Text("Coming soon...")
                .font(.skillBallr(.body))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkillBallrColors.background.ignoresSafeArea())
    }
}

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.skillBallr(.extraLargeTitle))
                .foregroundColor(.white)
            
            if let user = authManager.currentUser {
                VStack(spacing: 10) {
                    Text("Name: \(user.firstName) \(user.lastName)")
                        .font(.skillBallr(.body))
                        .foregroundColor(.white)
                    
                    Text("Email: \(user.email)")
                        .font(.skillBallr(.body))
                        .foregroundColor(.white)
                    
                    Text("Role: \(user.role.rawValue)")
                        .font(.skillBallr(.body))
                        .foregroundColor(.white)
                    
                    if let position = user.position {
                        Text("Position: \(position.rawValue)")
                            .font(.skillBallr(.body))
                            .foregroundColor(.white)
                    }
                }
            }
            
            SkillBallrButton(
                title: "Sign Out",
                action: {
                    Task {
                        await authManager.signOut()
                    }
                },
                style: .destructive
            )
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkillBallrColors.background.ignoresSafeArea())
    }
}

// MARK: - Preview
#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
        .environmentObject(SubscriptionManager())
}