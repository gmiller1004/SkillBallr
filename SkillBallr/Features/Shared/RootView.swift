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
                AuthenticationView()
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

/// Authentication view for login/signup
struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole: UserRole = .player
    @State private var selectedPosition: PlayerPosition = .qb
    @State private var age = ""
    
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
                VStack(spacing: 40) {
                    // Logo and header
                    headerSection
                    
                    // Authentication form
                    authenticationForm
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            // SkillBallr Logo
            Image("SkillBallr Logo Medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            VStack(spacing: 16) {
                Text("Welcome to SkillBallr")
                    .font(.skillBallr(.largeTitle))
                    .foregroundColor(.white)
                
                Text(isSignUpMode ? "Create your account to get started" : "Sign in to continue your journey")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
    
    private var authenticationForm: some View {
        SkillBallrCard {
            VStack(spacing: 24) {
                // Mode toggle
                Picker("Mode", selection: $isSignUpMode) {
                    Text("Sign In").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Form fields
                VStack(spacing: 20) { // Increased spacing for iPad
                    if isSignUpMode {
                        SkillBallrTextField(
                            title: "First Name",
                            text: $firstName,
                            placeholder: "Enter your first name"
                        )
                        
                        SkillBallrTextField(
                            title: "Last Name",
                            text: $lastName,
                            placeholder: "Enter your last name"
                        )
                        
                        // Role selection
                        VStack(alignment: .leading, spacing: 16) { // Increased spacing for iPad
                            Text("I am a...")
                                .font(.skillBallr(.label))
                                .foregroundColor(.white)
                            
                            Picker("Role", selection: $selectedRole) {
                                ForEach(UserRole.allCases) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Position selection (for players)
                        if selectedRole == .player {
                            VStack(alignment: .leading, spacing: 16) { // Increased spacing for iPad
                                Text("Position")
                                    .font(.skillBallr(.label))
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2), spacing: 12) { // 3 columns on iPad
                                    ForEach(PlayerPosition.allCases) { position in
                                        Button(action: { selectedPosition = position }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: position.icon)
                                                    .foregroundColor(selectedPosition == position ? .white : SkillBallrColors.skillOrange)
                                                Text(position.rawValue)
                                                    .font(.skillBallr(.caption))
                                                    .foregroundColor(selectedPosition == position ? .white : SkillBallrColors.skillOrange)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60) // Taller on iPad
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedPosition == position ? SkillBallrColors.skillOrange : SkillBallrColors.overlayBackground)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            
                            SkillBallrTextField(
                                title: "Age",
                                text: $age,
                                placeholder: "Enter your age",
                                keyboardType: .numberPad
                            )
                        }
                    }
                    
                    SkillBallrTextField(
                        title: "Email",
                        text: $email,
                        placeholder: "Enter your email",
                        keyboardType: .emailAddress
                    )
                    
                    SkillBallrTextField(
                        title: "Password",
                        text: $password,
                        placeholder: "Enter your password",
                        isSecure: true
                    )
                }
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.skillBallr(.caption))
                        .foregroundColor(SkillBallrColors.error)
                        .padding(.horizontal)
                }
                
                // Action buttons
                VStack(spacing: 16) { // Increased spacing for iPad
                    SkillBallrButton(
                        title: isSignUpMode ? "Create Account" : "Sign In",
                        action: handleAuthentication,
                        size: .kidFriendly, // Use kid-friendly size
                        isDisabled: !isFormValid || authManager.isLoading
                    )
                    
                    if !isSignUpMode {
                        SkillBallrButton(
                            title: "Sign in with Apple",
                            action: handleAppleSignIn,
                            style: .outline,
                            size: .large, // Large but not kid-friendly for secondary action
                            isDisabled: authManager.isLoading
                        )
                    }
                    
                    Button(action: handleForgotPassword) {
                        Text("Forgot Password?")
                            .font(.skillBallr(.bodySecondary))
                            .foregroundColor(SkillBallrColors.skillOrange)
                    }
                    .disabled(authManager.isLoading)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty &&
                   authManager.validateEmail(email) && authManager.validatePassword(password)
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - Actions
    private func handleAuthentication() {
        Task {
            do {
                if isSignUpMode {
                    let ageInt = age.isEmpty ? nil : Int(age)
                    try await authManager.signUp(
                        email: email,
                        password: password,
                        firstName: firstName,
                        lastName: lastName,
                        role: selectedRole,
                        position: selectedRole == .player ? selectedPosition : nil,
                        age: ageInt
                    )
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                print("Authentication failed: \(error)")
            }
        }
    }
    
    private func handleAppleSignIn() {
        Task {
            do {
                try await authManager.signInWithApple()
            } catch {
                print("Apple Sign In failed: \(error)")
            }
        }
    }
    
    private func handleForgotPassword() {
        Task {
            do {
                try await authManager.resetPassword(email: email)
            } catch {
                print("Password reset failed: \(error)")
            }
        }
    }
}

/// Main tab view for authenticated users
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
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
    }
}

// MARK: - Placeholder Views
struct PlayerView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Player Dashboard")
                    .font(.skillBallr(.headline))
                    .foregroundColor(.white)
                Text("Coming in Phase 2")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkillBallrColors.background)
            .navigationTitle("Player")
        }
    }
}

struct CoachView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Coach Dashboard")
                    .font(.skillBallr(.headline))
                    .foregroundColor(.white)
                Text("Coming in Phase 2")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkillBallrColors.background)
            .navigationTitle("Coach")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 16) {
                        Text(user.fullName)
                            .font(.skillBallr(.headline))
                            .foregroundColor(.white)
                        
                        Text(user.email)
                            .font(.skillBallr(.body))
                            .foregroundColor(.white.opacity(0.7))
                        
                        SkillBallrBadge(text: user.role.rawValue)
                        
                        if let position = user.position {
                            SkillBallrBadge(text: position.fullName, style: .secondary)
                        }
                    }
                }
                
                SkillBallrButton(
                    title: "Sign Out",
                    action: handleSignOut,
                    style: .destructive
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkillBallrColors.background)
            .navigationTitle("Profile")
        }
    }
    
    private func handleSignOut() {
        Task {
            await authManager.signOut()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
        .environmentObject(SubscriptionManager())
}
