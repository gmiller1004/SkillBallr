import Foundation
import Combine
import UIKit

/// Interceptor for handling common network concerns like authentication, retries, and error handling
class NetworkInterceptor {
    
    // MARK: - Properties
    private let networkManager: NetworkManager
    private var retryCount: [String: Int] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    // MARK: - Request Interception
    
    /// Intercept and modify requests before sending
    func interceptRequest(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        
        // Add common headers
        for (key, value) in NetworkConfiguration.defaultHeaders {
            modifiedRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add request timestamp for analytics
        modifiedRequest.setValue(
            ISO8601DateFormatter().string(from: Date()),
            forHTTPHeaderField: "X-Request-Time"
        )
        
        // Add device information
        modifiedRequest.setValue(
            UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
            forHTTPHeaderField: "X-Device-ID"
        )
        
        // Log request if enabled
        NetworkLogger.logRequest(modifiedRequest)
        
        return modifiedRequest
    }
    
    // MARK: - Response Interception
    
    /// Intercept and handle responses
    func interceptResponse(
        _ response: HTTPURLResponse,
        data: Data,
        for request: URLRequest
    ) throws -> Data {
        
        // Log response if enabled
        NetworkLogger.logResponse(response, data: data)
        
        // Handle rate limiting
        if response.statusCode == NetworkConstants.StatusCodes.tooManyRequests {
            handleRateLimit(response: response)
        }
        
        // Reset retry count on successful response
        let requestKey = requestKey(for: request)
        retryCount.removeValue(forKey: requestKey)
        
        return data
    }
    
    // MARK: - Error Handling
    
    /// Handle network errors with retry logic
    func handleError(
        _ error: Error,
        for request: URLRequest
    ) async throws -> Never {
        
        let requestKey = requestKey(for: request)
        let currentRetryCount = retryCount[requestKey] ?? 0
        
        // Log error
        NetworkLogger.logError(error, for: request)
        
        // Check if we should retry
        if shouldRetry(error: error, retryCount: currentRetryCount) {
            retryCount[requestKey] = currentRetryCount + 1
            
            // Calculate delay with exponential backoff
            let delay = calculateRetryDelay(retryCount: currentRetryCount)
            
            // Wait before retrying
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            // This would typically retry the request, but since we're in an interceptor,
            // we'll let the calling code handle the retry logic
            throw NetworkError.requestFailed("Retry attempt \(currentRetryCount + 1) failed: \(error.localizedDescription)")
        }
        
        // Don't retry, throw the original error
        throw error
    }
    
    // MARK: - Authentication Handling
    
    /// Handle authentication errors
    @MainActor
    func handleAuthenticationError(for request: URLRequest) {
        // Clear stored JWT token
        networkManager.clearJWTToken()
        
        // Post notification for UI to handle logout
        NotificationCenter.default.post(
            name: .authenticationExpired,
            object: nil,
            userInfo: ["request": request]
        )
    }
    
    // MARK: - Rate Limiting
    
    private func handleRateLimit(response: HTTPURLResponse) {
        // Extract rate limit headers
        let remainingRequests = response.allHeaderFields["X-RateLimit-Remaining"] as? String
        let resetTime = response.allHeaderFields["X-RateLimit-Reset"] as? String
        
        // Post notification for UI to show rate limit message
        NotificationCenter.default.post(
            name: .rateLimitExceeded,
            object: nil,
            userInfo: [
                "remainingRequests": remainingRequests ?? "0",
                "resetTime": resetTime ?? ""
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func requestKey(for request: URLRequest) -> String {
        return "\(request.httpMethod ?? "GET")_\(request.url?.absoluteString ?? "")"
    }
    
    private func shouldRetry(error: Error, retryCount: Int) -> Bool {
        // Don't retry if we've exceeded max attempts
        guard retryCount < NetworkConfiguration.maxRetryAttempts else { return false }
        
        // Don't retry if it's not a network error
        guard let networkError = error as? NetworkError else { return false }
        
        // Retry on server errors and timeouts
        switch networkError {
        case .serverError, .unknown, .requestFailed:
            return true
        case .badRequest, .unauthorized, .forbidden, .notFound:
            return false
        default:
            return false
        }
    }
    
    private func calculateRetryDelay(retryCount: Int) -> TimeInterval {
        if NetworkConstants.RetryPolicies.exponentialBackoff {
            let baseDelay = NetworkConfiguration.retryDelay
            let exponentialDelay = baseDelay * pow(2.0, Double(retryCount))
            return min(exponentialDelay, NetworkConstants.RetryPolicies.maxRetryDelay)
        } else {
            return NetworkConfiguration.retryDelay
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let authenticationExpired = Notification.Name("authenticationExpired")
    static let rateLimitExceeded = Notification.Name("rateLimitExceeded")
    static let networkConnectionLost = Notification.Name("networkConnectionLost")
    static let networkConnectionRestored = Notification.Name("networkConnectionRestored")
}

// MARK: - Network Reachability
import Network

class NetworkReachability {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkReachability")
    
    @Published var isConnected: Bool = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                
                if path.status == .satisfied {
                    NotificationCenter.default.post(name: .networkConnectionRestored, object: nil)
                } else {
                    NotificationCenter.default.post(name: .networkConnectionLost, object: nil)
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
