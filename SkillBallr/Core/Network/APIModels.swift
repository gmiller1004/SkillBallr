import Foundation

// MARK: - Authentication Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let confirmPassword: String
    let role: String // "player" | "coach" | "parent"
    let position: String? // Optional, for players only
    let firstName: String
    let lastName: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let user: UserResponse
    let token: String
}

// MARK: - User Models

struct UserResponse: Codable {
    let id: String
    let email: String
    let role: String
    let position: String?
    let firstName: String
    let lastName: String
    let createdAt: String // ISO8601 date string
}

struct UserUpdateRequest: Codable {
    let firstName: String?
    let lastName: String?
    let position: String?
    let age: Int?
}

// MARK: - Team Models

struct TeamResponse: Codable {
    let id: String
    let name: String
    let coachId: String
    let league: String // "pop_warner" | "flag_football" | "high_school"
    let players: [String] // Array of player IDs
    let createdAt: String // ISO8601 date string
}

struct CreateTeamRequest: Codable {
    let name: String
    let league: String
    let players: [String]
}

struct JoinTeamRequest: Codable {
    let inviteCode: String
}

// MARK: - Play Models

struct PlayResponse: Codable {
    let id: String
    let teamId: String
    let name: String
    let description: String
    let diagram: String? // JSON string representation of diagram data
    let analysis: String? // JSON string representation of AI analysis results
    let effectiveness: Int?
    let createdAt: String // ISO8601 date string
}

struct CreatePlayRequest: Codable {
    let teamId: String
    let name: String
    let description: String
    let diagram: String? // JSON string representation
    let analysis: String? // JSON string representation
    let effectiveness: Int?
}

// MARK: - AI Analysis Models

struct PlayAnalysisRequest: Codable {
    let formation: String
    let routes: [String]
    let blocking: String
}

struct AnalyzePlayRequest: Codable {
    let playData: PlayAnalysisRequest
    let defenseType: String
}

struct PlayAnalysisResponse: Codable {
    let success: Bool
    let analysis: PlayAnalysisResult
    let timestamp: String // ISO8601 date string
}

struct PlayAnalysisResult: Codable {
    let effectiveness: Int
    let strengths: [String]
    let weaknesses: [String]
    let recommendations: [String]
}

// MARK: - Progress Models

struct ProgressResponse: Codable {
    let id: String
    let userId: String
    let moduleId: String
    let score: Int
    let badges: [String]
    let streakDays: Int
    let completedAt: String // ISO8601 date string
}

struct CreateProgressRequest: Codable {
    let userId: String
    let moduleId: String
    let score: Int
    let badges: [String]
    let streakDays: Int
}

// MARK: - Module Sync Models

struct ModuleCheckResponse: Codable {
    let needsUpdate: Bool
    let latestVersion: String
    let moduleId: String
}

struct ModuleResponse: Codable {
    let id: String
    let position: String
    let version: String
    let title: String
    let text: String
    let videoUrl: String?
    let quizQuestions: [QuizQuestionResponse]
    let diagrams: [DiagramResponse]
    let updatedAt: String // ISO8601 date string
}

struct QuizQuestionResponse: Codable {
    let question: String
    let answers: [String]
    let correct: Int // Index of correct answer
}

struct DiagramResponse: Codable {
    let url: String
    let description: String
}

// MARK: - Contact Models

struct ContactRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
}

struct ContactResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Upload Models

struct UploadResponse: Codable {
    let success: Bool
    let url: String?
    let message: String
}

// MARK: - Health Models

struct HealthResponse: Codable {
    let status: String
    let timestamp: String // ISO8601 date string
    let environment: String
}

// MARK: - Empty Response

struct EmptyResponse: Codable {
    // Used for endpoints that don't return data
}

// MARK: - Error Response

struct APIErrorResponse: Codable {
    let message: String
    let code: String?
    let details: [String: String]?
}
