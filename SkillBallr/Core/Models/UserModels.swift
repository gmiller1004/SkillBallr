import Foundation

/// User role enumeration for the SkillBallr app
enum UserRole: String, CaseIterable, Identifiable, Codable {
    case player = "Player"
    case coach = "Coach"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .player: return "figure.walk.diamond.fill"
        case .coach: return "person.3.fill"
        }
    }
    
    var description: String {
        switch self {
        case .player: return "Join as a player to track your skills and progress"
        case .coach: return "Join as a coach to manage teams and track player development"
        }
    }
}

/// Player position enumeration for football positions
enum PlayerPosition: String, CaseIterable, Identifiable, Codable {
    case qb = "QB"
    case wr = "WR"
    case lb = "LB"
    case rb = "RB"
    
    var id: String { self.rawValue }
    
    var fullName: String {
        switch self {
        case .qb: return "Quarterback"
        case .wr: return "Wide Receiver"
        case .lb: return "Linebacker"
        case .rb: return "Running Back"
        }
    }
    
    var icon: String {
        switch self {
        case .qb: return "football.fill"
        case .wr: return "figure.run"
        case .lb: return "shield.lefthalf.filled"
        case .rb: return "figure.strengthtraining.traditional"
        }
    }
    
    var description: String {
        switch self {
        case .qb: return "Lead the offense and make smart decisions"
        case .wr: return "Catch passes and run precise routes"
        case .lb: return "Defend against the run and pass"
        case .rb: return "Run the ball and block for the quarterback"
        }
    }
}

/// Subscription tier enumeration
enum SubscriptionTier: String, CaseIterable, Identifiable, Codable {
    case free = "free"
    case playerPremium = "player_premium"
    case coachPro = "coach_pro"
    case familyUnlimited = "family_unlimited"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .playerPremium: return "Player Premium"
        case .coachPro: return "Coach Pro"
        case .familyUnlimited: return "Family Unlimited"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .playerPremium: return "$4.99/month"
        case .coachPro: return "$9.99/month"
        case .familyUnlimited: return "$14.99/month"
        }
    }
    
    var features: [Feature] {
        switch self {
        case .free:
            return [
                .basicEducation,
                .limitedQuizzes,
                .basicPlaybookViewer
            ]
        case .playerPremium:
            return [
                .allPositions,
                .unlimitedQuizzes,
                .progressBadges,
                .arPlaybookViewer,
                .selfReviewUpload,
                .advancedAnimations
            ]
        case .coachPro:
            return [
                .playbookUpload,
                .aiAnalysis,
                .teamManagement,
                .teamInvites,
                .dashboardAnalytics,
                .playExport
            ]
        case .familyUnlimited:
            return [
                .allFeatures,
                .multiTeamSupport,
                .familyAccounts,
                .positionDepthCharts,
                .historicalTracking,
                .prioritySupport
            ]
        }
    }
}

/// Feature enumeration for subscription tiers
enum Feature: String, CaseIterable, Identifiable, Codable {
    case basicEducation = "basic_education"
    case allPositions = "all_positions"
    case limitedQuizzes = "limited_quizzes"
    case unlimitedQuizzes = "unlimited_quizzes"
    case progressBadges = "progress_badges"
    case basicPlaybookViewer = "basic_playbook_viewer"
    case arPlaybookViewer = "ar_playbook_viewer"
    case advancedAnimations = "advanced_animations"
    case selfReviewUpload = "self_review_upload"
    case playbookUpload = "playbook_upload"
    case aiAnalysis = "ai_analysis"
    case teamManagement = "team_management"
    case teamInvites = "team_invites"
    case dashboardAnalytics = "dashboard_analytics"
    case playExport = "play_export"
    case multiTeamSupport = "multi_team_support"
    case familyAccounts = "family_accounts"
    case positionDepthCharts = "position_depth_charts"
    case historicalTracking = "historical_tracking"
    case prioritySupport = "priority_support"
    case allFeatures = "all_features"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .basicEducation: return "Basic Education Modules"
        case .allPositions: return "All Position Modules"
        case .limitedQuizzes: return "Limited Quizzes (3/month)"
        case .unlimitedQuizzes: return "Unlimited Quizzes"
        case .progressBadges: return "Progress Badges & Streaks"
        case .basicPlaybookViewer: return "Basic Playbook Viewer"
        case .arPlaybookViewer: return "AR Playbook Viewer"
        case .advancedAnimations: return "Advanced Animations"
        case .selfReviewUpload: return "Self-Review Video Upload"
        case .playbookUpload: return "Playbook Upload & Management"
        case .aiAnalysis: return "AI Play Analysis"
        case .teamManagement: return "Team Management"
        case .teamInvites: return "Team Invites & Sharing"
        case .dashboardAnalytics: return "Dashboard Analytics"
        case .playExport: return "Play Export to Wristbands"
        case .multiTeamSupport: return "Multi-Team Support"
        case .familyAccounts: return "Family Accounts"
        case .positionDepthCharts: return "Position Depth Charts"
        case .historicalTracking: return "Historical Play Tracking"
        case .prioritySupport: return "Priority Support"
        case .allFeatures: return "All Premium Features"
        }
    }
}

/// User profile model
struct UserProfile: Identifiable, Codable {
    let id: String
    var email: String
    var firstName: String
    var lastName: String
    var role: UserRole
    var position: PlayerPosition?
    var teamId: String?
    var subscriptionTier: SubscriptionTier
    var createdAt: Date
    var updatedAt: Date
    
    // Player-specific properties
    var age: Int?
    var parentId: String? // For COPPA compliance
    
    // Coach-specific properties
    var teamName: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        if let position = position {
            return "\(fullName) - \(position.fullName)"
        }
        return fullName
    }
    
    init(id: String = UUID().uuidString,
         email: String,
         firstName: String,
         lastName: String,
         role: UserRole,
         position: PlayerPosition? = nil,
         teamId: String? = nil,
         subscriptionTier: SubscriptionTier = .free,
         age: Int? = nil,
         parentId: String? = nil,
         teamName: String? = nil) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.position = position
        self.teamId = teamId
        self.subscriptionTier = subscriptionTier
        self.age = age
        self.parentId = parentId
        self.teamName = teamName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Family account model for COPPA compliance
struct FamilyAccount: Identifiable, Codable {
    let id: String
    let parentId: String
    var children: [String] // Array of child user IDs
    var subscriptionTier: SubscriptionTier
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         parentId: String,
         children: [String] = [],
         subscriptionTier: SubscriptionTier = .free) {
        self.id = id
        self.parentId = parentId
        self.children = children
        self.subscriptionTier = subscriptionTier
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
