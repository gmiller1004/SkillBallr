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
    
    // MARK: - Initialization
    init() {
        // Check for existing authentication state
        checkAuthenticationState()
    }
    
    // MARK: - Public Methods
    
    /// Sign up a new user
    func signUp(email: String, password: String, firstName: String, lastName: String, role: UserRole, position: PlayerPosition? = nil, age: Int? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual Firebase authentication
            // For now, create a mock user profile
            let userProfile = UserProfile(
                email: email,
                firstName: firstName,
                lastName: lastName,
                role: role,
                position: position,
                age: age
            )
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Set authenticated state
            await MainActor.run {
                self.currentUser = userProfile
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            // TODO: Save to Firebase
            // TODO: Save to Core Data
            // TODO: Track analytics event
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
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
    func signInWithApple() async throws {
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
            
            // Create authorization controller
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            // Handle the authorization result
            let result = try await withCheckedThrowingContinuation { continuation in
                let delegate = AppleSignInDelegate(continuation: continuation)
                authorizationController.delegate = delegate
                authorizationController.presentationContextProvider = delegate
                authorizationController.performRequests()
            }
            
            // Process the Apple ID credential
            let credential = result.credential as! ASAuthorizationAppleIDCredential
            
            // Create user profile from Apple ID data
            let userProfile = UserProfile(
                id: credential.user, // Apple user ID
                email: credential.email ?? "user@icloud.com",
                firstName: credential.fullName?.givenName ?? "Apple",
                lastName: credential.fullName?.familyName ?? "User",
                role: .player, // Default role, can be updated later
                position: .qb // Default position, can be updated later
            )
            
            await MainActor.run {
                self.currentUser = userProfile
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            // TODO: Save user profile to backend and local storage
            
            // TODO: Send Apple ID data to your backend for user creation/authentication
            // You'll need to send the credential.user (Apple user ID) and credential.identityToken
            // to your backend to create a JWT token
            
            print("✅ Apple Sign In successful for user: \(credential.user)")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign out the current user
    func signOut() async {
        isLoading = true
        
        // TODO: Sign out from Firebase
        // TODO: Clear Core Data cache
        // TODO: Clear user defaults
        
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
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
