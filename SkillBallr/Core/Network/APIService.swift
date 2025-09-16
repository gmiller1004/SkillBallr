import Foundation
import Combine

/// Service layer for handling API requests with business logic
@MainActor
class APIService: ObservableObject {
    
    // MARK: - Properties
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    // MARK: - Authentication Services
    
    /// Register a new user
    func register(
        email: String,
        password: String,
        confirmPassword: String,
        role: UserRole,
        position: PlayerPosition? = nil,
        firstName: String,
        lastName: String
    ) async throws -> AuthResponse {
        
        let request = RegisterRequest(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            role: role.rawValue.lowercased(),
            position: position?.rawValue,
            firstName: firstName,
            lastName: lastName
        )
        
        let response: AuthResponse = try await networkManager.request(
            endpoint: .register,
            responseType: AuthResponse.self,
            method: .POST,
            body: try encode(request)
        )
        
        // Store JWT token
        networkManager.setJWTToken(response.token)
        
        return response
    }
    
    /// Login with email and password
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        
        let response: AuthResponse = try await networkManager.request(
            endpoint: .login,
            responseType: AuthResponse.self,
            method: .POST,
            body: try encode(request)
        )
        
        // Store JWT token
        networkManager.setJWTToken(response.token)
        
        return response
    }
    
    /// Logout current user
    func logout() async throws {
        _ = try await networkManager.request(
            endpoint: .logout,
            responseType: EmptyResponse.self,
            method: .POST
        )
        
        // Clear JWT token
        networkManager.clearJWTToken()
    }
    
    // MARK: - User Services
    
    /// Get current user information
    func getCurrentUser(userId: String) async throws -> UserResponse {
        return try await networkManager.request(
            endpoint: .getUser(userId: userId),
            responseType: UserResponse.self
        )
    }
    
    /// Update user information
    func updateUser(userId: String, userData: UserUpdateRequest) async throws -> UserResponse {
        return try await networkManager.request(
            endpoint: .updateUser(userId: userId),
            responseType: UserResponse.self,
            method: .PUT,
            body: try encode(userData)
        )
    }
    
    // MARK: - Team Services
    
    /// Get user's teams
    func getTeams() async throws -> [TeamResponse] {
        return try await networkManager.request(
            endpoint: .getTeams,
            responseType: [TeamResponse].self
        )
    }
    
    /// Create a new team
    func createTeam(name: String, league: String, players: [String] = []) async throws -> TeamResponse {
        let request = CreateTeamRequest(
            name: name,
            league: league,
            players: players
        )
        
        return try await networkManager.request(
            endpoint: .createTeam,
            responseType: TeamResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    /// Get specific team details
    func getTeam(teamId: String) async throws -> TeamResponse {
        return try await networkManager.request(
            endpoint: .getTeam(teamId: teamId),
            responseType: TeamResponse.self
        )
    }
    
    /// Join a team with invite code
    func joinTeam(inviteCode: String) async throws -> TeamResponse {
        let request = JoinTeamRequest(inviteCode: inviteCode)
        
        return try await networkManager.request(
            endpoint: .joinTeam,
            responseType: TeamResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    // MARK: - Play Services
    
    /// Get plays for a team
    func getPlays(teamId: String? = nil) async throws -> [PlayResponse] {
        return try await networkManager.request(
            endpoint: .getPlays(teamId: teamId),
            responseType: [PlayResponse].self
        )
    }
    
    /// Create a new play
    func createPlay(
        teamId: String,
        name: String,
        description: String,
        diagram: [String: Any]? = nil,
        analysis: [String: Any]? = nil,
        effectiveness: Int? = nil
    ) async throws -> PlayResponse {
        
        // Convert dictionaries to JSON strings
        let diagramString: String?
        if let diagram = diagram {
            let data = try JSONSerialization.data(withJSONObject: diagram)
            diagramString = String(data: data, encoding: .utf8)
        } else {
            diagramString = nil
        }
        
        let analysisString: String?
        if let analysis = analysis {
            let data = try JSONSerialization.data(withJSONObject: analysis)
            analysisString = String(data: data, encoding: .utf8)
        } else {
            analysisString = nil
        }
        
        let request = CreatePlayRequest(
            teamId: teamId,
            name: name,
            description: description,
            diagram: diagramString,
            analysis: analysisString,
            effectiveness: effectiveness
        )
        
        return try await networkManager.request(
            endpoint: .createPlay,
            responseType: PlayResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    /// Get specific play details
    func getPlay(playId: String) async throws -> PlayResponse {
        return try await networkManager.request(
            endpoint: .getPlay(playId: playId),
            responseType: PlayResponse.self
        )
    }
    
    /// Delete a play
    func deletePlay(playId: String) async throws {
        _ = try await networkManager.request(
            endpoint: .deletePlay(playId: playId),
            responseType: EmptyResponse.self,
            method: .DELETE
        )
    }
    
    // MARK: - AI Analysis Services
    
    /// Analyze a play with AI
    func analyzePlay(
        playData: PlayAnalysisRequest,
        defenseType: String
    ) async throws -> PlayAnalysisResponse {
        
        let request = AnalyzePlayRequest(
            playData: playData,
            defenseType: defenseType
        )
        
        return try await networkManager.request(
            endpoint: .analyzePlay,
            responseType: PlayAnalysisResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    // MARK: - Progress Services
    
    /// Get user progress
    func getUserProgress(userId: String) async throws -> [ProgressResponse] {
        return try await networkManager.request(
            endpoint: .getUserProgress(userId: userId),
            responseType: [ProgressResponse].self
        )
    }
    
    /// Create progress entry
    func createProgressEntry(
        userId: String,
        moduleId: String,
        score: Int,
        badges: [String] = [],
        streakDays: Int = 0
    ) async throws -> ProgressResponse {
        
        let request = CreateProgressRequest(
            userId: userId,
            moduleId: moduleId,
            score: score,
            badges: badges,
            streakDays: streakDays
        )
        
        return try await networkManager.request(
            endpoint: .createProgressEntry,
            responseType: ProgressResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    // MARK: - Module Sync Services
    
    /// Check for module updates
    func checkModuleUpdates(position: String, version: String) async throws -> ModuleCheckResponse {
        return try await networkManager.request(
            endpoint: .checkModuleUpdates(position: position, version: version),
            responseType: ModuleCheckResponse.self
        )
    }
    
    /// Get module updates
    func getModuleUpdates(position: String, version: String) async throws -> ModuleResponse {
        return try await networkManager.request(
            endpoint: .getModuleUpdates(position: position, version: version),
            responseType: ModuleResponse.self
        )
    }
    
    // MARK: - File Upload Services
    
    /// Upload play diagram
    func uploadPlayDiagram(
        playId: String,
        imageData: Data,
        fileName: String
    ) async throws -> UploadResponse {
        
        let responseData = try await networkManager.uploadFile(
            endpoint: .uploadPlayDiagram,
            fileData: imageData,
            fileName: fileName,
            mimeType: "image/jpeg",
            additionalFields: ["playId": playId]
        )
        
        return try decode(UploadResponse.self, from: responseData)
    }
    
    // MARK: - Contact Services
    
    /// Submit contact form
    func submitContact(
        name: String,
        email: String,
        subject: String,
        message: String
    ) async throws -> ContactResponse {
        
        let request = ContactRequest(
            name: name,
            email: email,
            subject: subject,
            message: message
        )
        
        return try await networkManager.request(
            endpoint: .submitContact,
            responseType: ContactResponse.self,
            method: .POST,
            body: try encode(request)
        )
    }
    
    /// Check API health
    func checkHealth() async throws -> HealthResponse {
        return try await networkManager.request(
            endpoint: .getHealth,
            responseType: HealthResponse.self
        )
    }
    
    // MARK: - Helper Methods
    
    private func encode<T: Codable>(_ object: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(object)
        } catch {
            throw NetworkError.encodingFailed(error.localizedDescription)
        }
    }
    
    private func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
}
