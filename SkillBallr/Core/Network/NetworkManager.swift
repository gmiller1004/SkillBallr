import Foundation
import Combine

/// Main network manager for handling all API communications with SkillBallr.com
@MainActor
class NetworkManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = true
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private let baseURL: URL
    private var jwtToken: String?
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    nonisolated init(baseURL: String = "https://skillballr.com") {
        self.baseURL = URL(string: baseURL)!
        self.session = URLSession.shared
        
        // Load stored JWT token
        self.jwtToken = UserDefaults.standard.string(forKey: "jwt_token")
    }
    
    // MARK: - Token Management
    func setJWTToken(_ token: String) {
        self.jwtToken = token
        UserDefaults.standard.set(token, forKey: "jwt_token")
    }
    
    func clearJWTToken() {
        self.jwtToken = nil
        UserDefaults.standard.removeObject(forKey: "jwt_token")
    }
    
    var isAuthenticated: Bool {
        return jwtToken != nil
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) async throws -> T {
        
        isLoading = true
        defer { isLoading = false }
        
        let request = try buildRequest(endpoint: endpoint, method: method, body: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try handleHTTPResponse(httpResponse)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    // MARK: - File Upload Method
    func uploadFile(
        endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        additionalFields: [String: String] = [:]
    ) async throws -> Data {
        
        isLoading = true
        defer { isLoading = false }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let request = try buildMultipartRequest(
            endpoint: endpoint,
            boundary: boundary,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            additionalFields: additionalFields
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try handleHTTPResponse(httpResponse)
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    private func buildRequest(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Data?
    ) throws -> URLRequest {
        
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add JWT token if available and endpoint requires authentication
        if endpoint.requiresAuth, let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for POST/PUT requests
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func buildMultipartRequest(
        endpoint: APIEndpoint,
        boundary: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        additionalFields: [String: String]
    ) throws -> URLRequest {
        
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add JWT token if endpoint requires authentication
        if endpoint.requiresAuth, let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Build multipart body
        var body = Data()
        
        // Add additional fields
        for (key, value) in additionalFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return request
    }
    
    private func handleHTTPResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            // Success
            break
        case 400:
            throw NetworkError.badRequest
        case 401:
            // Clear invalid token
            clearJWTToken()
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(response.statusCode)
        default:
            throw NetworkError.unknown(response.statusCode)
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case unknown(Int)
    case requestFailed(String)
    case decodingFailed(String)
    case encodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest:
            return "Bad request - please check your input"
        case .unauthorized:
            return "Unauthorized - please sign in again"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknown(let code):
            return "Unknown error (\(code))"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .encodingFailed(let message):
            return "Failed to encode request: \(message)"
        }
    }
}
