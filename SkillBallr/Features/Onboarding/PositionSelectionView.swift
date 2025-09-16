import SwiftUI

/// Second screen in onboarding - Position selection (for players only)
struct PositionSelectionView: View {
    @EnvironmentObject private var onboardingState: OnboardingState
    @State private var selectedPosition: PlayerPosition? = nil
    @State private var age = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    SkillBallrColors.veryDarkBlue,
                    SkillBallrColors.lighterCenter,
                    SkillBallrColors.veryDarkBlue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Position Selection
                    positionSelectionSection
                    
                    // Age Input
                    ageInputSection
                    
                    // Continue Button
                    continueButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 600) // Constrain width for better readability on iPad
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("What's your position?")
                .font(.skillBallr(.extraLargeTitle))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Select the position you play or want to learn")
                .font(.skillBallr(.body))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var positionSelectionSection: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2), spacing: 16) {
                ForEach(PlayerPosition.allCases) { position in
                    PositionSelectionCard(
                        position: position,
                        isSelected: selectedPosition == position
                    ) {
                        selectedPosition = position
                    }
                }
            }
        }
    }
    
    private var ageInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Age")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            SkillBallrTextField(
                title: "Age",
                text: $age,
                placeholder: "Enter your age",
                keyboardType: .numberPad
            )
            
            Text("Age helps us customize your learning experience")
                .font(.skillBallr(.caption))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var continueButton: some View {
        SkillBallrButton(
            title: "Continue",
            action: navigateToAccountCreation,
            size: .kidFriendly,
            isDisabled: !isFormValid
        )
        .padding(.top, 16)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        selectedPosition != nil && 
        !age.isEmpty && 
        Int(age) != nil && 
        (Int(age) ?? 0) >= 5 && 
        (Int(age) ?? 0) <= 14
    }
    
    // MARK: - Actions
    
    private func navigateToAccountCreation() {
        // Store the selected position and age, then navigate to account creation
        guard let position = selectedPosition,
              let ageInt = Int(age) else { return }
        
        onboardingState.setPosition(position, age: ageInt)
    }
}

// MARK: - Position Selection Card

struct PositionSelectionCard: View {
    let position: PlayerPosition
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: position.icon)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 32, weight: .medium))
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                
                // Position abbreviation
                Text(position.rawValue)
                    .font(.skillBallr(.cardTitle))
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                
                // Full name
                Text(position.fullName)
                    .font(.skillBallr(.caption))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? SkillBallrColors.skillOrange : SkillBallrColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? SkillBallrColors.skillOrange : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    PositionSelectionView()
}
