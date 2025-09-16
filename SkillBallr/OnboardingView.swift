//
//  OnboardingView.swift
//  SkillBallr
//
//  Created by Greg Miller on 9/16/25.
//

import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedRole: UserRole? = nil
    @State private var selectedPosition: PlayerPosition? = nil
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    
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
                VStack(spacing: 40) {
                    // Header section
                    headerSection
                    
                    // Main content card
                    mainContentCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(spacing: 32) {
            // SkillBallr Logo
            Image("SkillBallr Logo Medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            // Welcome Text
            VStack(spacing: 16) {
                Text("Master football.")
                    .font(.skillBallr(.largeTitle))
                    .foregroundColor(.white)
                
                Text("Master anything.")
                    .font(.skillBallr(.largeTitle))
                    .foregroundColor(SkillBallrColors.skillOrange)
                
                Text("AI-native platform for youth football education with position-specific training, play analysis, team management and interactive learning modules.")
                    .font(.skillBallr(.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top, 60)
    }
    
    private var mainContentCard: some View {
        SkillBallrCard(padding: 32) {
            VStack(spacing: 32) {
                roleSelectionSection
                
                if selectedRole == .player {
                    positionSelectionSection
                }
                
                personalInformationSection
                nextButton
            }
        }
        .padding(.bottom, 60)
    }
    
    private var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Your Role")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(UserRole.allCases) { role in
                    RoleSelectionCard(
                        role: role,
                        isSelected: selectedRole == role
                    ) {
                        selectedRole = role
                        // Reset position when role changes
                        if role == .coach {
                            selectedPosition = nil
                        }
                    }
                }
            }
        }
    }
    
    private var positionSelectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Your Position")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
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
    
    private var personalInformationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.skillBallr(.headline))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                SkillBallrTextField(
                    title: "First Name",
                    text: $firstName,
                    placeholder: "Enter your first name"
                )
                
                SkillBallrTextField(
                    title: "Last Name",
                    text: $lastName,
                    placeholder: "Enter your last name"
                )
                
                if selectedRole == .player {
                    SkillBallrTextField(
                        title: "Age",
                        text: $age,
                        placeholder: "Enter your age",
                        keyboardType: .numberPad
                    )
                }
                
                SkillBallrTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email address",
                    keyboardType: .emailAddress
                )
            }
        }
    }
    
    private var nextButton: some View {
        SkillBallrButton(
            title: "Start for free",
            action: handleNextButton,
            isDisabled: !isFormValid
        )
        .padding(.top, 16)
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        guard let role = selectedRole else { return false }
        
        if role == .player && selectedPosition == nil {
            return false
        }
        
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    
    // MARK: - Actions
    private func handleNextButton() {
        // TODO: API Integration - Send onboarding data to backend
        print("Onboarding Complete!")
        print("Role: \(selectedRole?.rawValue ?? "N/A")")
        print("Position: \(selectedPosition?.rawValue ?? "N/A")")
        print("Name: \(firstName) \(lastName)")
        print("Email: \(email)")
        
        // Complete onboarding
        appState.completeOnboarding()
        
        // TODO: Navigate to the main app content
    }
}

// MARK: - Custom Components
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: role.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(.skillBallr(.cardTitle))
                        .foregroundColor(isSelected ? .white : .white)
                    
                    Text(role.description)
                        .font(.skillBallr(.bodySecondary))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? SkillBallrColors.skillOrange : SkillBallrColors.overlayBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? SkillBallrColors.skillOrange : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PositionSelectionCard: View {
    let position: PlayerPosition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: position.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                
                Text(position.rawValue)
                    .font(.skillBallr(.sectionTitle))
                    .foregroundColor(isSelected ? .white : SkillBallrColors.skillOrange)
                
                Text(position.fullName)
                    .font(.skillBallr(.caption))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? SkillBallrColors.skillOrange : SkillBallrColors.overlayBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? SkillBallrColors.skillOrange : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(AppState())
}