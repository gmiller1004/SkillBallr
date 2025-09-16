//
//  OnboardingView.swift
//  SkillBallr
//
//  Created by Greg Miller on 9/16/25.
//

import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var onboardingState = OnboardingState()

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    SkillBallrColors.veryDarkBlue,
                    SkillBallrColors.lighterCenter,
                    SkillBallrColors.veryDarkBlue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Onboarding Flow
            switch onboardingState.currentStep {
                case .roleSelection:
                    RoleSelectionView()
                        .environmentObject(onboardingState)
                        .environmentObject(authManager)
                    
                case .positionSelection:
                    PositionSelectionView()
                        .environmentObject(onboardingState)
                        .environmentObject(authManager)
                    
                case .accountCreation:
                    AccountCreationView()
                        .environmentObject(onboardingState)
                        .environmentObject(authManager)
                    
                case .emailVerification:
                    // This is handled within AccountCreationView as a sheet
                    AccountCreationView()
                        .environmentObject(onboardingState)
                        .environmentObject(authManager)
                    
                case .completed:
                    // Onboarding completed, user will be taken to main app
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: SkillBallrColors.skillOrange))
                            .scaleEffect(1.5)
                        Text("Setting up your account...")
                            .font(.skillBallr(.body))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 16)
                    }
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // User has been authenticated, complete onboarding
                onboardingState.completeOnboarding()
                
                // Update app state
                appState.currentUserProfile = authManager.currentUser
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
}