import Foundation

// MARK: - Authentication API Models

/// Request model for sending verification code
struct SendVerificationRequest: Codable {
    let email: String
}

/// Response model for sending verification code
struct SendVerificationResponse: Codable {
    let message: String
    let expiresIn: Int
}

/// Request model for email signup/signin
struct EmailAuthRequest: Codable {
    let email: String
    let code: String
    let role: String?
    let position: String?
    let firstName: String?
    let lastName: String?
    
    init(email: String, code: String, role: String? = nil, position: String? = nil, firstName: String? = nil, lastName: String? = nil) {
        self.email = email
        self.code = code
        self.role = role
        self.position = position
        self.firstName = firstName
        self.lastName = lastName
    }
}

/// Response model for email signup/signin
struct EmailAuthResponse: Codable {
    let user: APIUser
    let token: String
    let isLogin: Bool
}

/// API User model (matches backend response)
struct APIUser: Codable {
    let id: String
    let email: String
    let role: String
    let position: String?
    let firstName: String
    let lastName: String
    let createdAt: String
}

// MARK: - Apple Sign In Models

/// Request model for Apple Sign In
struct AppleSignInRequest: Codable {
    let appleUserId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let identityToken: String
}

/// Response model for Apple Sign In
struct AppleSignInResponse: Codable {
    let user: APIUser
    let token: String
    let isNewUser: Bool
}

// MARK: - Error Models

/// API Error response
struct APIError: Codable, Error {
    let message: String
    let code: String?
    let details: [String: String]?
    
    var localizedDescription: String {
        return message
    }
}

// MARK: - Network Error Extensions

extension NetworkError {
    static func fromAPIError(_ apiError: APIError) -> NetworkError {
        return .requestFailed(apiError.message)
    }
}
