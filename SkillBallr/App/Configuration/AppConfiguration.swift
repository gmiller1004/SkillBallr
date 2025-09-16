import Foundation

/// App configuration and constants for SkillBallr
struct AppConfiguration {
    
    // MARK: - App Information
    static let appName = "SkillBallr"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - API Configuration
    static let baseURL = "https://api.skillballr.com"
    static let apiVersion = "v1"
    
    // MARK: - Firebase Configuration
    static let firebaseProjectId = "skillballr-ios"
    static let firebaseStorageBucket = "skillballr-ios.appspot.com"
    
    // MARK: - Grok API Configuration
    static let grokAPIBaseURL = "https://api.x.ai"
    static let grokAPIVersion = "v1"
    
    // MARK: - Feature Flags
    static let isAREnabled = true
    static let isAIAnalysisEnabled = true
    static let isOfflineModeEnabled = true
    static let isFamilyAccountsEnabled = true
    
    // MARK: - Subscription Configuration
    static let freeQuizLimit = 3
    static let freeModuleLimit = 1
    static let trialPeriodDays = 7
    
    // MARK: - UI Configuration
    static let defaultAnimationDuration: Double = 0.3
    static let defaultCornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let extraLargePadding: CGFloat = 32
    
    // MARK: - Content Configuration
    static let maxVideoSizeMB = 100
    static let maxImageSizeMB = 10
    static let supportedVideoFormats = ["mp4", "mov", "avi"]
    static let supportedImageFormats = ["jpg", "jpeg", "png", "pdf"]
    
    // MARK: - Analytics Events
    enum AnalyticsEvent: String {
        case userSignup = "user_signup"
        case moduleStarted = "module_started"
        case moduleCompleted = "module_completed"
        case quizAttempted = "quiz_attempted"
        case quizPassed = "quiz_passed"
        case subscriptionPurchased = "subscription_purchased"
        case playbookUploaded = "playbook_uploaded"
        case aiAnalysisRequested = "ai_analysis_requested"
        case arViewerOpened = "ar_viewer_opened"
        case badgeEarned = "badge_earned"
        case streakStarted = "streak_started"
        case streakBroken = "streak_broken"
    }
    
    // MARK: - User Defaults Keys
    enum UserDefaultsKey: String {
        case hasCompletedOnboarding = "has_completed_onboarding"
        case lastSyncDate = "last_sync_date"
        case userProfile = "user_profile"
        case subscriptionTier = "subscription_tier"
        case offlineModules = "offline_modules"
        case quizAttempts = "quiz_attempts"
        case badgesEarned = "badges_earned"
        case currentStreak = "current_streak"
        case lastActivityDate = "last_activity_date"
        case hasSeenTutorial = "has_seen_tutorial"
        case preferredPosition = "preferred_position"
        case notificationsEnabled = "notifications_enabled"
    }
    
    // MARK: - Notification Identifiers
    enum NotificationIdentifier: String {
        case dailyReminder = "daily_reminder"
        case streakReminder = "streak_reminder"
        case newModuleAvailable = "new_module_available"
        case quizReminder = "quiz_reminder"
        case badgeEarned = "badge_earned"
        case teamInvite = "team_invite"
        case playbookShared = "playbook_shared"
    }
    
    // MARK: - Error Messages
    enum ErrorMessage: String {
        case networkError = "Please check your internet connection and try again."
        case serverError = "Something went wrong on our end. Please try again later."
        case invalidCredentials = "Invalid email or password. Please try again."
        case emailAlreadyExists = "An account with this email already exists."
        case subscriptionRequired = "This feature requires a premium subscription."
        case offlineModeUnavailable = "This feature is not available in offline mode."
        case fileUploadFailed = "Failed to upload file. Please try again."
        case aiAnalysisFailed = "AI analysis failed. Please try again."
        case arNotSupported = "AR features are not supported on this device."
        case quizLimitReached = "You've reached your monthly quiz limit. Upgrade to continue."
        case moduleLimitReached = "You've reached your module limit. Upgrade to continue."
    }
    
    // MARK: - Success Messages
    enum SuccessMessage: String {
        case profileUpdated = "Profile updated successfully!"
        case moduleCompleted = "Congratulations! Module completed!"
        case quizPassed = "Great job! Quiz passed!"
        case badgeEarned = "New badge earned!"
        case streakContinued = "Streak continued!"
        case subscriptionActivated = "Subscription activated successfully!"
        case playbookUploaded = "Playbook uploaded successfully!"
        case teamJoined = "Successfully joined team!"
        case playbookShared = "Playbook shared with team!"
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let minPasswordLength = 8
        static let maxNameLength = 50
        static let maxEmailLength = 100
        static let minAge = 5
        static let maxAge = 18
        static let maxTeamNameLength = 100
        static let maxPlaybookNameLength = 100
    }
    
    // MARK: - Cache Configuration
    struct Cache {
        static let maxCacheSizeMB = 500
        static let cacheExpirationHours = 24
        static let imageCacheSizeMB = 100
        static let videoCacheSizeMB = 300
    }
    
    // MARK: - Performance Configuration
    struct Performance {
        static let maxConcurrentDownloads = 3
        static let downloadTimeoutSeconds = 30
        static let requestTimeoutSeconds = 15
        static let maxRetryAttempts = 3
    }
}
