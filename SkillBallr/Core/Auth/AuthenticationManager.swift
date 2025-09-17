import Foundation
import Combine
import AuthenticationServices
import CryptoKit
import SwiftUI

/// Authentication manager for handling user authentication
@MainActor
class AuthenticationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: UserProfile?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager()
    private var appleSignInDelegate: AppleSignInDelegate? // Keep delegate alive during Apple Sign In
    
    // MARK: - Initialization
    init() {
        // Check for existing authentication state
        checkAuthenticationState()
    }
    
    // MARK: - Public Methods
    
    /// Send sign-up verification code to email
    func sendSignUpCode(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = SendVerificationRequest(email: email)
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            let response: SendVerificationResponse = try await networkManager.request(
                endpoint: .sendVerification,
                responseType: SendVerificationResponse.self,
                method: .POST,
                body: requestData
            )
            
            await MainActor.run {
                self.isLoading = false
            }
            
            print("✅ Verification code sent to \(email). Expires in \(response.expiresIn) seconds")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to send verification code. Please try again."
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Send sign-in verification code to email
    func sendSignInCode(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = SendVerificationRequest(email: email)
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            let response: SendVerificationResponse = try await networkManager.request(
                endpoint: .sendVerification,
                responseType: SendVerificationResponse.self,
                method: .POST,
                body: requestData
            )
            
            await MainActor.run {
                self.isLoading = false
            }
            
            print("✅ Sign-in verification code sent to \(email). Expires in \(response.expiresIn) seconds")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to send verification code. Please try again."
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Verify sign-up code and create account
    func verifySignUpCode(email: String, code: String, firstName: String, lastName: String, role: UserRole, position: PlayerPosition? = nil, age: Int? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = EmailAuthRequest(
                email: email,
                code: code,
                role: role.rawValue.lowercased(),
                position: position?.rawValue ?? "", // Provide empty string instead of nil for coaches
                firstName: firstName,
                lastName: lastName
            )
            
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            let response: EmailAuthResponse = try await networkManager.request(
                endpoint: .emailSignup,
                responseType: EmailAuthResponse.self,
                method: .POST,
                body: requestData
            )
            
            // Store JWT token
            networkManager.setJWTToken(response.token)
            
            // Convert API user to local UserProfile
            let userProfile = UserProfile(
                id: response.user.id,
                email: response.user.email,
                firstName: response.user.firstName,
                lastName: response.user.lastName,
                role: UserRole(rawValue: response.user.role.capitalized) ?? role,
                position: response.user.position.flatMap { PlayerPosition(rawValue: $0) },
                age: age
            )
            
            await MainActor.run {
                self.currentUser = userProfile
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            print("✅ Account created successfully for \(email). New user: \(response.isLogin ? "No" : "Yes")")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Invalid verification code. Please try again."
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Verify sign-in code and authenticate user
    func verifySignInCode(email: String, code: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = EmailAuthRequest(
                email: email, 
                code: code,
                role: nil,
                position: "", // Provide empty string for sign-in
                firstName: nil,
                lastName: nil
            )
            
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            let response: EmailAuthResponse = try await networkManager.request(
                endpoint: .emailSignup, // Same endpoint handles both signup and signin
                responseType: EmailAuthResponse.self,
                method: .POST,
                body: requestData
            )
            
            // Store JWT token
            networkManager.setJWTToken(response.token)
            
            // Convert API user to local UserProfile
            let userProfile = UserProfile(
                id: response.user.id,
                email: response.user.email,
                firstName: response.user.firstName,
                lastName: response.user.lastName,
                role: UserRole(rawValue: response.user.role.capitalized) ?? .player,
                position: response.user.position.flatMap { PlayerPosition(rawValue: $0) }
            )
            
            await MainActor.run {
                self.currentUser = userProfile
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            print("✅ Sign-in successful for \(email). Existing user: \(response.isLogin ? "Yes" : "No")")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Invalid verification code. Please try again."
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in an existing user
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual Firebase authentication
            // For now, simulate successful login
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // TODO: Fetch user profile from Firebase
            // For now, create a mock user
            let mockUser = UserProfile(
                email: email,
                firstName: "John",
                lastName: "Doe",
                role: .player,
                position: .qb
            )
            
            await MainActor.run {
                self.currentUser = mockUser
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with Apple ID
    func signInWithApple(role: UserRole = .player, position: PlayerPosition? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate nonce for security
            let nonce = randomNonceString()
            let hashedNonce = sha256(nonce)
            
            // Create Apple ID request
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce
            
            print("🍎 Starting Apple Sign In request...")
            
            // Create authorization controller
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            // Handle the authorization result with timeout
            let result = try await withTaskTimeout(seconds: 30) {
                try await withCheckedThrowingContinuation { continuation in
                    self.appleSignInDelegate = AppleSignInDelegate(continuation: continuation)
                    authorizationController.delegate = self.appleSignInDelegate
                    authorizationController.presentationContextProvider = self.appleSignInDelegate
                    authorizationController.performRequests()
                }
            }
            
            // Clean up the delegate
            self.appleSignInDelegate = nil
            
            // Process the Apple ID credential
            let credential = result.credential as! ASAuthorizationAppleIDCredential
            
            // Send Apple ID data to backend for authentication/user creation
            try await authenticateWithAppleOnServer(credential: credential, role: role, position: position)
            
            print("✅ Apple Sign In successful for user: \(credential.user)")
            
        } catch {
            // Clean up the delegate in case of error
            self.appleSignInDelegate = nil
            
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
                // Handle timeout or other errors
                if error.localizedDescription.contains("timed out") {
                    userFriendlyMessage = "Apple Sign In timed out. Please try again."
                } else {
                    userFriendlyMessage = "Apple Sign In failed. Please try again or use email sign-in."
                }
            }
            
            await MainActor.run {
                self.errorMessage = userFriendlyMessage
                self.isLoading = false
            }
            
            // Don't throw the error for user cancellation - just log it
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                print("ℹ️ Apple Sign In canceled by user")
            } else {
                print("❌ Apple Sign In error: \(error)")
                throw error
            }
        }
    }
    
    /// Authenticate with Apple credentials on the server
    private func authenticateWithAppleOnServer(credential: ASAuthorizationAppleIDCredential, role: UserRole, position: PlayerPosition?) async throws {
        
        // Prepare request data
        let requestData = AppleSignInRequest(
            appleUserId: credential.user,
            email: credential.email ?? "user@icloud.com",
            firstName: credential.fullName?.givenName ?? "Apple",
            lastName: credential.fullName?.familyName ?? "User",
            role: role.rawValue.lowercased(),
            position: position?.rawValue ?? ""
        )
        
        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(requestData)
        
        // Make API call to Apple Sign In endpoint
        let response: AppleSignInResponse = try await networkManager.request(
            endpoint: .appleSignIn,
            responseType: AppleSignInResponse.self,
            method: .POST,
            body: requestBody
        )
        
        // Store JWT token
        networkManager.setJWTToken(response.token)
        
        // Convert API user to local UserProfile
        let userProfile = UserProfile(
            id: response.user.id,
            email: response.user.email,
            firstName: response.user.firstName,
            lastName: response.user.lastName,
            role: UserRole(rawValue: response.user.role.capitalized) ?? role,
            position: response.user.position.flatMap { PlayerPosition(rawValue: $0) }
        )
        
        await MainActor.run {
            self.currentUser = userProfile
            self.isAuthenticated = true
            self.isLoading = false
        }
        
        print("✅ Apple Sign In API success - isNewUser: \(response.isNewUser), provider: \(response.provider)")
    }
    
    /// Sign out the current user
    func signOut() async {
        isLoading = true
        
        // Clear JWT token from network manager
        networkManager.clearJWTToken()
        
        // TODO: Call logout endpoint if needed
        // TODO: Sign out from Firebase
        // TODO: Clear Core Data cache
        
        // Simulate sign out delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
            self.errorMessage = nil
        }
    }
    
    /// Reset password for email
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement Firebase password reset
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            await MainActor.run {
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Update user profile
    func updateProfile(_ user: UserProfile) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Update in Firebase
            // TODO: Update in Core Data
            
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationState() {
        // TODO: Check Firebase authentication state
        // TODO: Load user profile from Core Data
        
        // For now, assume not authenticated
        isAuthenticated = false
        currentUser = nil
    }
    
    private func clearError() {
        errorMessage = nil
    }
}

// MARK: - Validation Methods
extension AuthenticationManager {
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= AppConfiguration.Validation.minPasswordLength
    }
    
    func validateName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               name.count <= AppConfiguration.Validation.maxNameLength
    }
    
    func validateAge(_ age: Int) -> Bool {
        return age >= AppConfiguration.Validation.minAge && age <= AppConfiguration.Validation.maxAge
    }
}

// MARK: - Error Types
extension AuthenticationManager {
    enum AuthError: LocalizedError {
        case invalidEmail
        case invalidPassword
        case invalidName
        case invalidAge
        case networkError
        case serverError
        case userNotFound
        case emailAlreadyExists
        case weakPassword
        case tooManyRequests
        
        var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return "Please enter a valid email address."
            case .invalidPassword:
                return "Password must be at least \(AppConfiguration.Validation.minPasswordLength) characters long."
            case .invalidName:
                return "Please enter a valid name."
            case .invalidAge:
                return "Age must be between \(AppConfiguration.Validation.minAge) and \(AppConfiguration.Validation.maxAge)."
            case .networkError:
                return AppConfiguration.ErrorMessage.networkError.rawValue
            case .serverError:
                return AppConfiguration.ErrorMessage.serverError.rawValue
            case .userNotFound:
                return "No account found with this email address."
            case .emailAlreadyExists:
                return AppConfiguration.ErrorMessage.emailAlreadyExists.rawValue
            case .weakPassword:
                return "Password is too weak. Please choose a stronger password."
            case .tooManyRequests:
                return "Too many attempts. Please try again later."
            }
        }
    }
}

// MARK: - Apple Sign In Helper Methods
extension AuthenticationManager {
    
    /// Generate a random nonce string for Apple Sign In security
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    /// Hash a nonce string using SHA256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    /// Helper function to add timeout to async operations
    private func withTaskTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "TimeoutError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
            }
            
            guard let result = try await group.next() else {
                throw NSError(domain: "TimeoutError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
            }
            
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("🍎 Apple Sign In authorization completed successfully")
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("🍎 Apple Sign In authorization failed with error: \(error)")
        if let authError = error as? ASAuthorizationError {
            print("🍎 Apple Sign In error code: \(authError.code.rawValue)")
        }
        continuation.resume(throwing: error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign In presentation")
        }
        return window
    }
}
