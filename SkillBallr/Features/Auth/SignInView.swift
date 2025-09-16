import SwiftUI
import AuthenticationServices

/// Sign-in screen for existing users
struct SignInView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var verificationCode = ""
    @State private var codeSent = false
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
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        if codeSent {
                            // Code Verification
                            codeVerificationSection
                        } else {
                            // Sign In Options
                            signInOptionsSection
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
            .navigationTitle("Sign In")
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
        VStack(spacing: 16) {
            Image("SkillBallr Logo Medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 80, 
                       height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 80)
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text(codeSent ? "Check Your Email" : "Welcome Back!")
                    .font(.skillBallr(.extraLargeTitle))
                    .foregroundColor(.white)
                
                Text(codeSent ? "Enter the verification code we sent to \(email)" : "Sign in to continue your football journey")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var signInOptionsSection: some View {
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
            
            // Email Sign In
            emailSignInSection
        }
    }
    
    private var emailSignInSection: some View {
        VStack(spacing: 20) {
            Text("Continue with Email")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            SkillBallrTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email address",
                keyboardType: .emailAddress
            )
            
            SkillBallrButton(
                title: "Send Sign In Code",
                action: handleSendSignInCode,
                size: .kidFriendly,
                isDisabled: !isValidEmail || authManager.isLoading
            )
        }
    }
    
    private var codeVerificationSection: some View {
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
            
            // Back to email input
            Button(action: {
                codeSent = false
                verificationCode = ""
            }) {
                Text("Use Different Email")
                    .font(.skillBallr(.bodySecondary))
                    .foregroundColor(.white.opacity(0.7))
                    .underline()
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
    
    private func handleSendSignInCode() {
        Task {
            do {
                try await authManager.sendSignInCode(email: email)
                
                await MainActor.run {
                    codeSent = true
                    countdownTimer = 60 // 60 second cooldown
                }
            } catch {
                print("Failed to send sign-in code: \(error)")
            }
        }
    }
    
    private func handleVerifyCode() {
        Task {
            do {
                try await authManager.verifySignInCode(email: email, code: verificationCode)
                
                // If successful, the user will be authenticated and taken to the main app
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to verify sign-in code: \(error)")
            }
        }
    }
    
    private func handleResendCode() {
        Task {
            do {
                try await authManager.sendSignInCode(email: email)
                countdownTimer = 60 // Reset cooldown
            } catch {
                print("Failed to resend sign-in code: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SignInView()
        .environmentObject(AuthenticationManager())
}
