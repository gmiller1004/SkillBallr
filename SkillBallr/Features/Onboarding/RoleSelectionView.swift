import SwiftUI

/// First screen in onboarding - Role selection (Player/Coach)
struct RoleSelectionView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var onboardingState: OnboardingState
    @State private var selectedRole: UserRole? = nil
    @State private var showingSignIn = false
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Title
                    headerSection
                    
                    // Role Selection
                    roleSelectionSection
                    
                    // Sign In Link
                    signInLinkSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 600) // Constrain width for better readability on iPad
            }
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            Image("SkillBallr Logo Medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 120, 
                       height: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 120)
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("Welcome to SkillBallr")
                    .font(.skillBallr(.extraLargeTitle))
                    .foregroundColor(.white)
                
                Text("Let's get you started with your football journey")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var roleSelectionSection: some View {
        VStack(spacing: 24) {
            Text("I am a...")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                ForEach(UserRole.allCases) { role in
                    RoleSelectionCard(
                        role: role,
                        isSelected: selectedRole == role
                    ) {
                        selectedRole = role
                    }
                }
            }
            
            // Continue Button
            if let role = selectedRole {
                SkillBallrButton(
                    title: "Continue",
                    action: {
                        navigateToNextScreen(for: role)
                    },
                    size: .kidFriendly
                )
                .padding(.top, 16)
            }
        }
    }
    
    private var signInLinkSection: some View {
        VStack(spacing: 16) {
            Text("Already have an account?")
                .font(.skillBallr(.bodySecondary))
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                showingSignIn = true
            }) {
                Text("Sign In")
                    .font(.skillBallr(.bodyMedium))
                    .foregroundColor(SkillBallrColors.skillOrange)
                    .underline()
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Actions
    
    private func navigateToNextScreen(for role: UserRole) {
        // Store the selected role and navigate to next step
        onboardingState.setRole(role)
    }
}

// MARK: - Role Selection Card

struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Icon
                Image(systemName: role.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                    .frame(width: 50)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(.skillBallr(.cardTitle))
                        .foregroundColor(.white)
                    
                    Text(role.description)
                        .font(.skillBallr(.bodySecondary))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? SkillBallrColors.skillOrange : .white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? SkillBallrColors.skillOrange.opacity(0.2) : SkillBallrColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? SkillBallrColors.skillOrange : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    RoleSelectionView()
        .environmentObject(AuthenticationManager())
}
