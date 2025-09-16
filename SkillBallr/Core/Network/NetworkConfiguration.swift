import Foundation

/// Configuration for network requests and API endpoints
struct NetworkConfiguration {
    
    // MARK: - Environment Configuration
    enum Environment {
        case development
        case staging
        case production
        
        var baseURL: String {
            switch self {
            case .development:
                return "http://localhost:5000"
            case .staging:
                return "https://staging.skillballr.com"
            case .production:
                return "https://skillballr.com"
            }
        }
        
        var timeoutInterval: TimeInterval {
            switch self {
            case .development:
                return 30.0 // Longer timeout for development
            case .staging, .production:
                return 15.0 // Standard timeout for production
            }
        }
        
        var enableLogging: Bool {
            switch self {
            case .development:
                return true
            case .staging:
                return true
            case .production:
                return false
            }
        }
    }
    
    // MARK: - Current Configuration
    static let current: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()
    
    // MARK: - API Configuration
    static let baseURL = current.baseURL
    static let timeoutInterval = current.timeoutInterval
    static let enableLogging = current.enableLogging
    
    // MARK: - Request Configuration
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "SkillBallr-iOS/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")"
    ]
    
    // MARK: - Retry Configuration
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
    
    // MARK: - File Upload Configuration
    static let maxFileSize: Int64 = 10 * 1024 * 1024 // 10MB
    static let allowedImageTypes = ["image/jpeg", "image/png", "image/gif"]
    static let allowedDocumentTypes = ["application/pdf", "image/jpeg", "image/png"]
    
    // MARK: - Cache Configuration
    static let cacheExpirationTime: TimeInterval = 300 // 5 minutes
    static let maxCacheSize: Int = 50 * 1024 * 1024 // 50MB
    
    // MARK: - Security Configuration
    static let enableCertificatePinning = current != .development
    static let enableRequestSigning = current == .production
    
    // MARK: - Analytics Configuration
    static let enableNetworkAnalytics = current != .development
}

// MARK: - Network Constants
struct NetworkConstants {
    
    // MARK: - HTTP Status Codes
    struct StatusCodes {
        static let ok = 200
        static let created = 201
        static let noContent = 204
        static let badRequest = 400
        static let unauthorized = 401
        static let forbidden = 403
        static let notFound = 404
        static let conflict = 409
        static let unprocessableEntity = 422
        static let tooManyRequests = 429
        static let internalServerError = 500
        static let badGateway = 502
        static let serviceUnavailable = 503
        static let gatewayTimeout = 504
    }
    
    // MARK: - API Rate Limits
    struct RateLimits {
        static let requestsPerMinute = 60
        static let requestsPerHour = 1000
        static let fileUploadsPerHour = 10
    }
    
    // MARK: - Timeouts
    struct Timeouts {
        static let request = NetworkConfiguration.timeoutInterval
        static let upload = 60.0 // 1 minute for file uploads
        static let download = 30.0 // 30 seconds for downloads
    }
    
    // MARK: - Retry Policies
    struct RetryPolicies {
        static let exponentialBackoff = true
        static let maxRetryDelay: TimeInterval = 10.0
        static let retryableStatusCodes = [
            StatusCodes.internalServerError,
            StatusCodes.badGateway,
            StatusCodes.serviceUnavailable,
            StatusCodes.gatewayTimeout
        ]
    }
}

// MARK: - Network Logging
struct NetworkLogger {
    static func logRequest(_ request: URLRequest) {
        guard NetworkConfiguration.enableLogging else { return }
        
        print("🚀 [REQUEST] \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "Unknown URL")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 [HEADERS] \(headers)")
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 [BODY] \(bodyString)")
        }
    }
    
    static func logResponse(_ response: HTTPURLResponse, data: Data?) {
        guard NetworkConfiguration.enableLogging else { return }
        
        print("📥 [RESPONSE] \(response.statusCode) \(response.url?.absoluteString ?? "Unknown URL")")
        
        if let headers = response.allHeaderFields as? [String: String], !headers.isEmpty {
            print("📋 [HEADERS] \(headers)")
        }
        
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("📦 [BODY] \(responseString)")
        }
    }
    
    static func logError(_ error: Error, for request: URLRequest) {
        guard NetworkConfiguration.enableLogging else { return }
        
        print("❌ [ERROR] \(error.localizedDescription) for \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "Unknown URL")")
    }
}
