import Foundation
import Combine

/// Manages the onboarding flow state and navigation
@MainActor
class OnboardingState: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .roleSelection
    @Published var selectedRole: UserRole? = nil
    @Published var selectedPosition: PlayerPosition? = nil
    @Published var playerAge: Int? = nil
    @Published var isCompleted = false
    
    // MARK: - Onboarding Steps
    enum OnboardingStep: String, CaseIterable, Identifiable {
        case roleSelection = "role_selection"
        case positionSelection = "position_selection"
        case accountCreation = "account_creation"
        case emailVerification = "email_verification"
        case completed = "completed"
        
        var id: String { self.rawValue }
        
        var title: String {
            switch self {
            case .roleSelection: return "Choose Your Role"
            case .positionSelection: return "Select Your Position"
            case .accountCreation: return "Create Your Account"
            case .emailVerification: return "Verify Your Email"
            case .completed: return "Welcome to SkillBallr!"
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to the next step in the onboarding flow
    func nextStep() {
        switch currentStep {
        case .roleSelection:
            if selectedRole == .player {
                currentStep = .positionSelection
            } else {
                // Skip position selection for coaches
                currentStep = .accountCreation
            }
            
        case .positionSelection:
            currentStep = .accountCreation
            
        case .accountCreation:
            // This step is handled by authentication success
            break
            
        case .emailVerification:
            // This step is handled by authentication success
            break
            
        case .completed:
            break
        }
    }
    
    /// Navigate back to the previous step
    func previousStep() {
        switch currentStep {
        case .roleSelection:
            // Can't go back from first step
            break
            
        case .positionSelection:
            currentStep = .roleSelection
            
        case .accountCreation:
            if selectedRole == .player {
                currentStep = .positionSelection
            } else {
                currentStep = .roleSelection
            }
            
        case .emailVerification:
            currentStep = .accountCreation
            
        case .completed:
            break
        }
    }
    
    /// Complete the onboarding process
    func completeOnboarding() {
        currentStep = .completed
        isCompleted = true
    }
    
    /// Reset the onboarding state
    func reset() {
        currentStep = .roleSelection
        selectedRole = nil
        selectedPosition = nil
        playerAge = nil
        isCompleted = false
    }
    
    // MARK: - Data Management
    
    /// Set the selected role and advance to next step
    func setRole(_ role: UserRole) {
        selectedRole = role
        nextStep()
    }
    
    /// Set the selected position and age, then advance to next step
    func setPosition(_ position: PlayerPosition, age: Int) {
        selectedPosition = position
        playerAge = age
        nextStep()
    }
    
    /// Navigate to account creation (used by coaches or after position selection)
    func goToAccountCreation() {
        currentStep = .accountCreation
    }
    
    /// Navigate to email verification
    func goToEmailVerification() {
        currentStep = .emailVerification
    }
    
    // MARK: - Validation
    
    /// Check if the current step's data is valid
    var isCurrentStepValid: Bool {
        switch currentStep {
        case .roleSelection:
            return selectedRole != nil
            
        case .positionSelection:
            return selectedPosition != nil && playerAge != nil
            
        case .accountCreation, .emailVerification:
            return true // These are handled by authentication
            
        case .completed:
            return true
        }
    }
    
    /// Get the progress percentage for the onboarding flow
    var progressPercentage: Double {
        let totalSteps = OnboardingStep.allCases.count
        let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        return Double(currentIndex) / Double(totalSteps - 1) // -1 because completed doesn't count for progress
    }
}

// MARK: - Onboarding Data Model

struct OnboardingData {
    let role: UserRole
    let position: PlayerPosition?
    let age: Int?
    
    var isPlayer: Bool {
        role == .player
    }
    
    var hasPosition: Bool {
        position != nil
    }
    
    var hasAge: Bool {
        age != nil
    }
}
