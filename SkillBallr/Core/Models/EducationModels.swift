import Foundation

/// Education module model for player learning content
struct EducationModule: Identifiable, Codable {
    let id: String
    let position: PlayerPosition
    let title: String
    let description: String
    let content: ModuleContent
    let quiz: Quiz
    let badges: [Badge]
    let estimatedTimeMinutes: Int
    let difficulty: DifficultyLevel
    let order: Int
    let isPremium: Bool
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String = UUID().uuidString,
         position: PlayerPosition,
         title: String,
         description: String,
         content: ModuleContent,
         quiz: Quiz,
         badges: [Badge] = [],
         estimatedTimeMinutes: Int,
         difficulty: DifficultyLevel = .beginner,
         order: Int,
         isPremium: Bool = false) {
        self.id = id
        self.position = position
        self.title = title
        self.description = description
        self.content = content
        self.quiz = quiz
        self.badges = badges
        self.estimatedTimeMinutes = estimatedTimeMinutes
        self.difficulty = difficulty
        self.order = order
        self.isPremium = isPremium
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Module content structure
struct ModuleContent: Codable {
    let text: String
    let videoURL: URL?
    let diagrams: [Diagram]
    let keyPoints: [String]
    
    init(text: String, videoURL: URL? = nil, diagrams: [Diagram] = [], keyPoints: [String] = []) {
        self.text = text
        self.videoURL = videoURL
        self.diagrams = diagrams
        self.keyPoints = keyPoints
    }
}

/// Diagram model for visual learning content
struct Diagram: Identifiable, Codable {
    let id: String
    let title: String
    let imageURL: URL?
    let description: String
    let annotations: [DiagramAnnotation]
    
    init(id: String = UUID().uuidString,
         title: String,
         imageURL: URL? = nil,
         description: String,
         annotations: [DiagramAnnotation] = []) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.description = description
        self.annotations = annotations
    }
}

/// Diagram annotation for interactive elements
struct DiagramAnnotation: Identifiable, Codable {
    let id: String
    let position: CGPoint
    let text: String
    let type: AnnotationType
    
    enum AnnotationType: String, Codable {
        case tooltip
        case highlight
        case arrow
        case circle
    }
    
    init(id: String = UUID().uuidString,
         position: CGPoint,
         text: String,
         type: AnnotationType = .tooltip) {
        self.id = id
        self.position = position
        self.text = text
        self.type = type
    }
}

/// Difficulty level enumeration
enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

/// Quiz model for module assessments
struct Quiz: Identifiable, Codable {
    let id: String
    let moduleId: String
    let questions: [QuizQuestion]
    let passingScore: Int // Percentage
    let timeLimitMinutes: Int?
    
    init(id: String = UUID().uuidString,
         moduleId: String,
         questions: [QuizQuestion],
         passingScore: Int = 70,
         timeLimitMinutes: Int? = nil) {
        self.id = id
        self.moduleId = moduleId
        self.questions = questions
        self.passingScore = passingScore
        self.timeLimitMinutes = timeLimitMinutes
    }
}

/// Quiz question model
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [QuizOption]
    let correctAnswerId: String
    let explanation: String
    let difficulty: DifficultyLevel
    
    init(id: String = UUID().uuidString,
         question: String,
         options: [QuizOption],
         correctAnswerId: String,
         explanation: String,
         difficulty: DifficultyLevel = .beginner) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswerId = correctAnswerId
        self.explanation = explanation
        self.difficulty = difficulty
    }
}

/// Quiz option model
struct QuizOption: Identifiable, Codable {
    let id: String
    let text: String
    let isCorrect: Bool
    
    init(id: String = UUID().uuidString, text: String, isCorrect: Bool = false) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
    }
}

/// Quiz attempt model for tracking progress
struct QuizAttempt: Identifiable, Codable {
    let id: String
    let userId: String
    let quizId: String
    let moduleId: String
    let answers: [QuizAnswer]
    let score: Int
    let timeSpentSeconds: Int
    let completedAt: Date
    let passed: Bool
    
    init(id: String = UUID().uuidString,
         userId: String,
         quizId: String,
         moduleId: String,
         answers: [QuizAnswer],
         score: Int,
         timeSpentSeconds: Int,
         completedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.quizId = quizId
        self.moduleId = moduleId
        self.answers = answers
        self.score = score
        self.timeSpentSeconds = timeSpentSeconds
        self.completedAt = completedAt
        self.passed = score >= 70 // Default passing score
    }
}

/// Quiz answer model
struct QuizAnswer: Identifiable, Codable {
    let id: String
    let questionId: String
    let selectedOptionId: String
    let isCorrect: Bool
    let timeSpentSeconds: Int
    
    init(id: String = UUID().uuidString,
         questionId: String,
         selectedOptionId: String,
         isCorrect: Bool,
         timeSpentSeconds: Int = 0) {
        self.id = id
        self.questionId = questionId
        self.selectedOptionId = selectedOptionId
        self.isCorrect = isCorrect
        self.timeSpentSeconds = timeSpentSeconds
    }
}

/// Badge model for gamification
struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: BadgeCategory
    let rarity: BadgeRarity
    let requirements: [BadgeRequirement]
    
    enum BadgeCategory: String, CaseIterable, Codable {
        case learning = "learning"
        case streak = "streak"
        case quiz = "quiz"
        case position = "position"
        case special = "special"
        
        var displayName: String {
            switch self {
            case .learning: return "Learning"
            case .streak: return "Streak"
            case .quiz: return "Quiz"
            case .position: return "Position"
            case .special: return "Special"
            }
        }
    }
    
    enum BadgeRarity: String, CaseIterable, Codable {
        case common = "common"
        case uncommon = "uncommon"
        case rare = "rare"
        case epic = "epic"
        case legendary = "legendary"
        
        var displayName: String {
            switch self {
            case .common: return "Common"
            case .uncommon: return "Uncommon"
            case .rare: return "Rare"
            case .epic: return "Epic"
            case .legendary: return "Legendary"
            }
        }
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .uncommon: return "green"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "gold"
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         iconName: String,
         category: BadgeCategory,
         rarity: BadgeRarity = .common,
         requirements: [BadgeRequirement] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.category = category
        self.rarity = rarity
        self.requirements = requirements
    }
}

/// Badge requirement model
struct BadgeRequirement: Identifiable, Codable {
    let id: String
    let type: RequirementType
    let targetValue: Int
    let currentValue: Int
    
    enum RequirementType: String, CaseIterable, Codable {
        case quizPassed = "quiz_passed"
        case moduleCompleted = "module_completed"
        case streakDays = "streak_days"
        case perfectScore = "perfect_score"
        case positionMastered = "position_mastered"
        
        var displayName: String {
            switch self {
            case .quizPassed: return "Quizzes Passed"
            case .moduleCompleted: return "Modules Completed"
            case .streakDays: return "Days Streak"
            case .perfectScore: return "Perfect Scores"
            case .positionMastered: return "Positions Mastered"
            }
        }
    }
    
    var isCompleted: Bool {
        return currentValue >= targetValue
    }
    
    var progressPercentage: Double {
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    init(id: String = UUID().uuidString,
         type: RequirementType,
         targetValue: Int,
         currentValue: Int = 0) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
    }
}

/// User progress model for tracking learning
struct UserProgress: Identifiable, Codable {
    let id: String
    let userId: String
    let moduleId: String
    let position: PlayerPosition
    let isCompleted: Bool
    let quizAttempts: [QuizAttempt]
    let badgesEarned: [Badge]
    let timeSpentMinutes: Int
    let lastAccessedAt: Date
    let completedAt: Date?
    
    var currentStreak: Int {
        // Calculate current streak based on completion dates
        return 0 // TODO: Implement streak calculation
    }
    
    var bestQuizScore: Int {
        return quizAttempts.map { $0.score }.max() ?? 0
    }
    
    var totalQuizAttempts: Int {
        return quizAttempts.count
    }
    
    init(id: String = UUID().uuidString,
         userId: String,
         moduleId: String,
         position: PlayerPosition,
         isCompleted: Bool = false,
         quizAttempts: [QuizAttempt] = [],
         badgesEarned: [Badge] = [],
         timeSpentMinutes: Int = 0,
         lastAccessedAt: Date = Date(),
         completedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.moduleId = moduleId
        self.position = position
        self.isCompleted = isCompleted
        self.quizAttempts = quizAttempts
        self.badgesEarned = badgesEarned
        self.timeSpentMinutes = timeSpentMinutes
        self.lastAccessedAt = lastAccessedAt
        self.completedAt = completedAt
    }
}
