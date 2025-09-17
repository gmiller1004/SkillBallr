import SwiftUI
import AuthenticationServices

/// Passwordless authentication view with Apple Sign In and email verification codes
struct PasswordlessAuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var verificationCode = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole: UserRole = .player
    @State private var selectedPosition: PlayerPosition = .qb
    @State private var age = ""
    @State private var codeSent = false
    @State private var countdownTimer = 0
    
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
                    
                    // Authentication Options
                    authenticationOptionsSection
                    
                    // Form Section (only shown if not using Apple Sign In)
                    if !isSignUpMode || codeSent {
                        formSection
                    }
                    
                    // Error message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.skillBallr(.caption))
                            .foregroundColor(SkillBallrColors.error)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 600) // Constrain width for better readability on iPad
            }
        }
        .onAppear {
            authManager.errorMessage = nil
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if countdownTimer > 0 {
                countdownTimer -= 1
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            Image("SkillBallr Logo Medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 120, height: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 120)
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text(isSignUpMode ? "Create Your Account" : "Welcome Back!")
                    .font(.skillBallr(.extraLargeTitle))
                    .foregroundColor(.white)
                
                Text(isSignUpMode ? "Join the SkillBallr community" : "Continue your football journey")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var authenticationOptionsSection: some View {
        VStack(spacing: 24) {
            // Apple Sign In Button (Primary)
            AppleSignInButton(
                authManager: authManager,
                isLoading: authManager.isLoading
            )
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                Text("or")
                    .font(.skillBallr(.bodySecondary))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16)
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Continue with Email Button
            SkillBallrButton(
                title: isSignUpMode ? "Continue with Email" : "Continue with Email",
                action: handleEmailAuthentication,
                style: .outline,
                size: .kidFriendly,
                isDisabled: authManager.isLoading || !isValidEmail
            )
            
            // Toggle between Sign In / Sign Up
            HStack {
                Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                    .font(.skillBallr(.bodySecondary))
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: { 
                    isSignUpMode.toggle()
                    resetForm()
                }) {
                    Text(isSignUpMode ? "Sign In" : "Sign Up")
                        .font(.skillBallr(.bodySecondary))
                        .foregroundColor(SkillBallrColors.skillOrange)
                        .underline()
                }
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 24) {
            if isSignUpMode && !codeSent {
                // Sign Up Form
                signUpFormSection
            } else {
                // Email Code Form
                emailCodeFormSection
            }
        }
    }
    
    private var signUpFormSection: some View {
        VStack(spacing: 16) {
            Text("Complete Your Profile")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
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
                VStack(alignment: .leading, spacing: 16) {
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
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Position")
                            .font(.skillBallr(.label))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2), spacing: 12) {
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
                                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedPosition == position ? SkillBallrColors.skillOrange : SkillBallrColors.cardBackground)
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
        }
    }
    
    private var emailCodeFormSection: some View {
        VStack(spacing: 16) {
            if codeSent {
                // Code Verification
                VStack(spacing: 16) {
                    Text("Check your email")
                        .font(.skillBallr(.headline))
                        .foregroundColor(.white)
                    
                    Text("We sent a 6-digit code to \(email)")
                        .font(.skillBallr(.body))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    SkillBallrTextField(
                        title: "Verification Code",
                        text: $verificationCode,
                        placeholder: "Enter 6-digit code",
                        keyboardType: .numberPad
                    )
                    
                    SkillBallrButton(
                        title: "Verify Code",
                        action: handleVerifyCode,
                        size: .kidFriendly,
                        isDisabled: !isValidCode || authManager.isLoading
                    )
                    
                    if countdownTimer > 0 {
                        Text("Resend code in \(countdownTimer)s")
                            .font(.skillBallr(.caption))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Button(action: handleResendCode) {
                            Text("Resend Code")
                                .font(.skillBallr(.bodySecondary))
                                .foregroundColor(SkillBallrColors.skillOrange)
                                .underline()
                        }
                    }
                }
            } else {
                // Email Input
                VStack(spacing: 16) {
                    Text(isSignUpMode ? "Enter your email to continue" : "Enter your email to sign in")
                        .font(.skillBallr(.headline))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    SkillBallrTextField(
                        title: "Email",
                        text: $email,
                        placeholder: "Enter your email",
                        keyboardType: .emailAddress
                    )
                    
                    SkillBallrButton(
                        title: isSignUpMode ? "Send Verification Code" : "Send Sign In Code",
                        action: handleSendCode,
                        size: .kidFriendly,
                        isDisabled: !isValidEmail || authManager.isLoading
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidEmail: Bool {
        authManager.validateEmail(email)
    }
    
    private var isValidCode: Bool {
        verificationCode.count == 6 && verificationCode.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Actions
    
    private func handleAppleSignIn() {
        // This method is no longer used since AppleSignInButton handles the flow directly
        print("Apple Sign In initiated through button")
    }
    
    private func handleEmailAuthentication() {
        // This will show the email form
        codeSent = false
    }
    
    private func handleSendCode() {
        Task {
            do {
                if isSignUpMode {
                    try await authManager.sendSignUpCode(email: email)
                } else {
                    try await authManager.sendSignInCode(email: email)
                }
                codeSent = true
                countdownTimer = 60 // 60 second cooldown
            } catch {
                print("Failed to send code: \(error)")
            }
        }
    }
    
    private func handleVerifyCode() {
        Task {
            do {
                if isSignUpMode {
                    try await authManager.verifySignUpCode(
                        email: email,
                        code: verificationCode,
                        firstName: firstName,
                        lastName: lastName,
                        role: selectedRole,
                        position: selectedRole == .player ? selectedPosition : nil,
                        age: selectedRole == .player ? Int(age) : nil
                    )
                } else {
                    try await authManager.verifySignInCode(email: email, code: verificationCode)
                }
            } catch {
                print("Failed to verify code: \(error)")
            }
        }
    }
    
    private func handleResendCode() {
        handleSendCode()
    }
    
    private func resetForm() {
        email = ""
        verificationCode = ""
        firstName = ""
        lastName = ""
        age = ""
        codeSent = false
        countdownTimer = 0
        authManager.errorMessage = nil
    }
}

// MARK: - Apple Sign In Button Component

struct AppleSignInButton: View {
    @ObservedObject var authManager: AuthenticationManager
    let isLoading: Bool
    var onboardingData: OnboardingData? = nil // Optional onboarding data for new users
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
                print("🍎 Apple Sign In button tapped")
            },
            onCompletion: { result in
                handleAppleSignInResult(result)
            }
        )
        .signInWithAppleButtonStyle(.black) // Use black style for dark background
        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 50) // iPad-optimized height
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity) // Constrain width on iPad
        .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16) // iPad-optimized corner radius
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
    
    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        Task { @MainActor in
            switch result {
            case .success(let authorization):
                print("🍎 Apple Sign In successful")
                
                // Process the Apple ID credential
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    print("❌ Failed to get Apple ID credential")
                    authManager.errorMessage = "Failed to get Apple ID credential"
                    return
                }
                
                // Call the proper Apple Sign In API method
                Task {
                    do {
                        try await authManager.signInWithApple(
                            role: onboardingData?.role ?? .player,
                            position: onboardingData?.position ?? .qb,
                            age: onboardingData?.age
                        )
                        print("✅ Apple Sign In completed successfully for user: \(appleIDCredential.user)")
                    } catch {
                        print("❌ Apple Sign In API failed: \(error)")
                        await MainActor.run {
                            authManager.errorMessage = "Failed to sign in with Apple. Please try again."
                            authManager.isLoading = false
                        }
                    }
                }
                
            case .failure(let error):
                print("❌ Apple Sign In failed: \(error)")
                
                // Handle specific Apple Sign In errors
                let userFriendlyMessage: String
                if let authError = error as? ASAuthorizationError {
                    switch authError.code {
                    case .canceled:
                        userFriendlyMessage = "Apple Sign In was canceled. Please try again if you'd like to continue."
                    case .failed:
                        userFriendlyMessage = "Apple Sign In failed. Please check your internet connection and try again."
                    case .invalidResponse:
                        userFriendlyMessage = "Invalid response from Apple. Please try again."
                    case .notHandled:
                        userFriendlyMessage = "Apple Sign In is not available. Please use email sign-in instead."
                    case .unknown:
                        userFriendlyMessage = "An unknown error occurred with Apple Sign In. Please try again."
                    case .notInteractive:
                        userFriendlyMessage = "Apple Sign In is not available in this context. Please use email sign-in instead."
                    case .matchedExcludedCredential:
                        userFriendlyMessage = "Apple Sign In credential is excluded. Please use email sign-in instead."
                    case .credentialImport:
                        userFriendlyMessage = "Apple Sign In credential import failed. Please try again or use email sign-in."
                    case .credentialExport:
                        userFriendlyMessage = "Apple Sign In credential export failed. Please try again or use email sign-in."
                    @unknown default:
                        userFriendlyMessage = "Apple Sign In failed. Please try again or use email sign-in."
                    }
                } else {
                    userFriendlyMessage = "Apple Sign In failed. Please try again or use email sign-in."
                }
                
                authManager.errorMessage = userFriendlyMessage
                authManager.isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PasswordlessAuthenticationView()
        .environmentObject(AuthenticationManager())
}
