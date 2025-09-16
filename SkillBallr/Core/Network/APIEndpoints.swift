import Foundation

/// Defines all API endpoints for the SkillBallr backend
enum APIEndpoint {
    // MARK: - Authentication Endpoints
    case register
    case login
    case logout
    case forgotPassword
    case sendVerification
    case verifyCode
    case emailSignup
    case appleSignIn
    
    // MARK: - User Management
    case getUser(userId: String)
    case updateUser(userId: String)
    case deleteUser(userId: String)
    
    // MARK: - Team Management
    case getTeams
    case createTeam
    case getTeam(teamId: String)
    case updateTeam(teamId: String)
    case deleteTeam(teamId: String)
    case joinTeam
    case leaveTeam(teamId: String)
    
    // MARK: - Play Management
    case getPlays(teamId: String?)
    case createPlay
    case getPlay(playId: String)
    case updatePlay(playId: String)
    case deletePlay(playId: String)
    
    // MARK: - AI Analysis
    case analyzePlay
    
    // MARK: - Progress Tracking
    case getUserProgress(userId: String)
    case createProgressEntry
    case updateProgressEntry(entryId: String)
    case deleteProgressEntry(entryId: String)
    
    // MARK: - Module Sync
    case checkModuleUpdates(position: String, version: String)
    case getModuleUpdates(position: String, version: String)
    
    // MARK: - Contact & Support
    case submitContact
    case getHealth
    
    // MARK: - File Upload
    case uploadPlayDiagram
    case uploadUserAvatar
    
    // MARK: - Computed Properties
    var path: String {
        switch self {
        // Authentication
        case .register:
            return "/api/auth/register"
        case .login:
            return "/api/auth/login"
        case .logout:
            return "/api/auth/logout"
        case .forgotPassword:
            return "/api/auth/forgot-password"
        case .sendVerification:
            return "/api/auth/send-verification"
        case .verifyCode:
            return "/api/auth/verify-code"
        case .emailSignup:
            return "/api/auth/email-signup"
        case .appleSignIn:
            return "/api/auth/apple-signin"
            
        // User Management
        case .getUser(let userId):
            return "/api/users/\(userId)"
        case .updateUser(let userId):
            return "/api/users/\(userId)"
        case .deleteUser(let userId):
            return "/api/users/\(userId)"
            
        // Team Management
        case .getTeams:
            return "/api/teams"
        case .createTeam:
            return "/api/teams"
        case .getTeam(let teamId):
            return "/api/teams/\(teamId)"
        case .updateTeam(let teamId):
            return "/api/teams/\(teamId)"
        case .deleteTeam(let teamId):
            return "/api/teams/\(teamId)"
        case .joinTeam:
            return "/api/teams/join"
        case .leaveTeam(let teamId):
            return "/api/teams/\(teamId)/leave"
            
        // Play Management
        case .getPlays(let teamId):
            if let teamId = teamId {
                return "/api/plays?teamId=\(teamId)"
            }
            return "/api/plays"
        case .createPlay:
            return "/api/plays"
        case .getPlay(let playId):
            return "/api/plays/\(playId)"
        case .updatePlay(let playId):
            return "/api/plays/\(playId)"
        case .deletePlay(let playId):
            return "/api/plays/\(playId)"
            
        // AI Analysis
        case .analyzePlay:
            return "/api/analyze-play"
            
        // Progress Tracking
        case .getUserProgress(let userId):
            return "/api/progress/\(userId)"
        case .createProgressEntry:
            return "/api/progress"
        case .updateProgressEntry(let entryId):
            return "/api/progress/\(entryId)"
        case .deleteProgressEntry(let entryId):
            return "/api/progress/\(entryId)"
            
        // Module Sync
        case .checkModuleUpdates(let position, let version):
            return "/api/modules/check?position=\(position)&version=\(version)"
        case .getModuleUpdates(let position, let version):
            return "/api/modules/updates?position=\(position)&version=\(version)"
            
        // Contact & Support
        case .submitContact:
            return "/api/contact"
        case .getHealth:
            return "/api/health"
            
        // File Upload
        case .uploadPlayDiagram:
            return "/api/plays/upload-diagram"
        case .uploadUserAvatar:
            return "/api/users/upload-avatar"
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .register, .login, .forgotPassword, .sendVerification, .verifyCode, .emailSignup, .appleSignIn, .submitContact, .getHealth:
            return false
        default:
            return true
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .register, .login, .sendVerification, .verifyCode, .emailSignup, .appleSignIn, .createTeam, .createPlay, .analyzePlay, .createProgressEntry, .submitContact, .uploadPlayDiagram, .uploadUserAvatar:
            return .POST
        case .updateUser, .updateTeam, .updatePlay, .updateProgressEntry:
            return .PUT
        case .deleteUser, .deleteTeam, .deletePlay, .deleteProgressEntry:
            return .DELETE
        case .logout, .leaveTeam:
            return .POST
        default:
            return .GET
        }
    }
}
