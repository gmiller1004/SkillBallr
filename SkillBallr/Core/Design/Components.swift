import SwiftUI

/// SkillBallr Design System - Reusable UI Components
/// Kid-friendly components optimized for touch interaction and readability

// MARK: - Button Components
struct SkillBallrButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var size: ButtonSize = .large
    var isDisabled: Bool = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case destructive
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        case extraLarge
        
        var height: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 48
            case .large: return 56
            case .extraLarge: return 64
            }
        }
        
        var font: Font {
            switch self {
            case .small: return SkillBallrTypography.caption
            case .medium: return SkillBallrTypography.bodyMedium
            case .large: return SkillBallrTypography.button
            case .extraLarge: return SkillBallrTypography.buttonLarge
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isDisabled)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return SkillBallrColors.skillBlue.opacity(0.3)
        }
        
        switch style {
        case .primary: return SkillBallrColors.skillOrange
        case .secondary: return SkillBallrColors.skillBlue
        case .outline: return Color.clear
        case .destructive: return SkillBallrColors.error
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .secondary, .destructive: return .white
        case .outline: return SkillBallrColors.skillOrange
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .secondary, .destructive: return Color.clear
        case .outline: return SkillBallrColors.skillOrange
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outline: return 2
        default: return 0
        }
    }
}

// MARK: - Card Components
struct SkillBallrCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16
    
    init(padding: CGFloat = 20, cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(SkillBallrColors.cardBackground)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Text Field Components
struct SkillBallrTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.skillBallr(.label))
                .foregroundColor(.white)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textFieldStyle(SkillBallrTextFieldStyle())
        }
    }
}

struct SkillBallrTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .font(.skillBallr(.textField))
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(SkillBallrColors.overlayBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Badge Components
struct SkillBallrBadge: View {
    let text: String
    var style: BadgeStyle = .primary
    
    enum BadgeStyle {
        case primary
        case secondary
        case success
        case warning
        case error
        
        var backgroundColor: Color {
            switch self {
            case .primary: return SkillBallrColors.skillOrange
            case .secondary: return SkillBallrColors.skillBlue
            case .success: return SkillBallrColors.success
            case .warning: return SkillBallrColors.warning
            case .error: return SkillBallrColors.error
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .secondary, .error: return .white
            case .success: return .white
            case .warning: return .black
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(.skillBallr(.caption))
            .foregroundColor(style.textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(style.backgroundColor)
            )
    }
}

// MARK: - Progress Components
struct SkillBallrProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(SkillBallrColors.skillOrange)
                    .frame(width: geometry.size.width * progress, height: height)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Loading Components
struct SkillBallrLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: SkillBallrColors.skillOrange))
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.skillBallr(.body))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkillBallrColors.background)
    }
}

// MARK: - Preview Helpers
#Preview("Components") {
    VStack(spacing: 20) {
        SkillBallrButton(title: "Primary Button", action: {})
        SkillBallrButton(title: "Secondary Button", action: {}, style: .secondary)
        SkillBallrButton(title: "Outline Button", action: {}, style: .outline)
        
        SkillBallrCard {
            VStack {
                Text("Card Content")
                    .foregroundColor(.white)
                SkillBallrBadge(text: "Badge")
            }
        }
        
        SkillBallrTextField(title: "Email", text: .constant(""), placeholder: "Enter email", keyboardType: .emailAddress)
    }
    .padding()
    .background(SkillBallrColors.background)
}
