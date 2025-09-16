import SwiftUI
import AuthenticationServices

/// Third screen in onboarding - Account creation (Apple Sign In or Email)
struct AccountCreationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var onboardingState: OnboardingState
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var showingEmailVerification = false
    
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
                    // Header
                    headerSection
                    
                    // Account Creation Options
                    accountCreationSection
                    
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
        .sheet(isPresented: $showingEmailVerification) {
            EmailVerificationView(email: email, firstName: firstName, lastName: lastName)
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Create Your Account")
                .font(.skillBallr(.extraLargeTitle))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Choose how you'd like to create your account")
                .font(.skillBallr(.body))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var accountCreationSection: some View {
        VStack(spacing: 24) {
            // Apple Sign In Button (Primary)
            AppleSignInButton(
                authManager: authManager,
                isLoading: authManager.isLoading,
                onboardingData: OnboardingData(
                    role: onboardingState.selectedRole ?? .player,
                    position: onboardingState.selectedPosition,
                    age: onboardingState.playerAge
                )
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
            
            // Email Form
            emailFormSection
        }
    }
    
    private var emailFormSection: some View {
        VStack(spacing: 20) {
            Text("Continue with Email")
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
                
                SkillBallrTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email address",
                    keyboardType: .emailAddress
                )
            }
            
            SkillBallrButton(
                title: "Send Verification Code",
                action: handleEmailSignUp,
                size: .kidFriendly,
                isDisabled: !isEmailFormValid || authManager.isLoading
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var isEmailFormValid: Bool {
        !firstName.isEmpty && 
        !lastName.isEmpty && 
        authManager.validateEmail(email)
    }
    
    // MARK: - Actions
    
    private func handleEmailSignUp() {
        Task {
            do {
                // Get role, position, and age from onboarding state
                let role = onboardingState.selectedRole ?? .player
                let position = onboardingState.selectedPosition
                let age = onboardingState.playerAge
                
                try await authManager.sendSignUpCode(email: email)
                
                await MainActor.run {
                    showingEmailVerification = true
                }
            } catch {
                print("Failed to send sign-up code: \(error)")
            }
        }
    }
}

// MARK: - Email Verification View

struct EmailVerificationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var onboardingState: OnboardingState
    @Environment(\.dismiss) private var dismiss
    
    let email: String
    let firstName: String
    let lastName: String
    
    @State private var verificationCode = ""
    @State private var countdownTimer = 0
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Check Your Email")
                            .font(.skillBallr(.extraLargeTitle))
                            .foregroundColor(.white)
                        
                        Text("We sent a 6-digit verification code to")
                            .font(.skillBallr(.body))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(email)
                            .font(.skillBallr(.bodyMedium))
                            .foregroundColor(SkillBallrColors.skillOrange)
                    }
                    .padding(.top, 40)
                    
                    // Verification Code Input
                    VStack(spacing: 20) {
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
                    }
                    
                    // Resend Code
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
                    
                    // Error message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.skillBallr(.caption))
                            .foregroundColor(SkillBallrColors.error)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Verify Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(SkillBallrColors.skillOrange)
                }
            }
        }
        .onAppear {
            countdownTimer = 60 // 60 second cooldown
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if countdownTimer > 0 {
                countdownTimer -= 1
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidCode: Bool {
        verificationCode.count == 6 && verificationCode.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Actions
    
    private func handleVerifyCode() {
        Task {
            do {
                // Get role, position, and age from onboarding state
                let role = onboardingState.selectedRole ?? .player
                let position = onboardingState.selectedPosition
                let age = onboardingState.playerAge
                
                try await authManager.verifySignUpCode(
                    email: email,
                    code: verificationCode,
                    firstName: firstName,
                    lastName: lastName,
                    role: role,
                    position: position,
                    age: age
                )
                
                // If successful, the user will be authenticated and taken to the main app
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to verify code: \(error)")
            }
        }
    }
    
    private func handleResendCode() {
        Task {
            do {
                try await authManager.sendSignUpCode(email: email)
                countdownTimer = 60 // Reset cooldown
            } catch {
                print("Failed to resend code: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AccountCreationView()
        .environmentObject(AuthenticationManager())
}
