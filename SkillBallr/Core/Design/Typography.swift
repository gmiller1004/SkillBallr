import SwiftUI

/// SkillBallr Design System - Typography
/// Optimized for youth-friendly readability and coach dashboard clarity
struct SkillBallrTypography {
    
    // MARK: - Display Styles (iPad-Optimized)
    /// Large title for hero sections (40pt on iPad, 32pt on iPhone)
    static let largeTitle = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 32, weight: .bold, design: .default)
    
    /// Extra large title for main headings (36pt on iPad, 28pt on iPhone)
    static let extraLargeTitle = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 28, weight: .semibold, design: .default)
    
    // MARK: - Heading Styles (iPad-Optimized)
    /// Main headline (28pt on iPad, 24pt on iPhone)
    static let headline = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24, weight: .semibold, design: .default)
    
    /// Section title (24pt on iPad, 20pt on iPhone)
    static let sectionTitle = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20, weight: .semibold, design: .default)
    
    /// Card title (22pt on iPad, 18pt on iPhone)
    static let cardTitle = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 18, weight: .semibold, design: .default)
    
    // MARK: - Body Text Styles (iPad-Optimized)
    /// Primary body text (20pt on iPad, 16pt on iPhone)
    static let body = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16, weight: .regular, design: .default)
    
    /// Body text with medium weight (20pt on iPad, 16pt on iPhone)
    static let bodyMedium = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16, weight: .medium, design: .default)
    
    /// Secondary body text (18pt on iPad, 14pt on iPhone)
    static let bodySecondary = Font.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .regular, design: .default)
    
    // MARK: - Interactive Elements
    /// Button text (18pt, semibold)
    static let button = Font.system(size: 18, weight: .semibold, design: .default)
    
    /// Large button text for primary actions (20pt, semibold)
    static let buttonLarge = Font.system(size: 20, weight: .semibold, design: .default)
    
    // MARK: - Small Text Styles
    /// Caption text (12pt, medium)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    
    /// Small caption (10pt, regular)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // MARK: - Form Elements
    /// Text field input (16pt, regular)
    static let textField = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Label text (16pt, medium)
    static let label = Font.system(size: 16, weight: .medium, design: .default)
    
    // MARK: - Navigation
    /// Tab bar text (12pt, medium)
    static let tabBar = Font.system(size: 12, weight: .medium, design: .default)
    
    /// Navigation title (17pt, semibold)
    static let navigationTitle = Font.system(size: 17, weight: .semibold, design: .default)
}

// MARK: - Font Extensions
extension Font {
    /// Custom font with dynamic type support
    static func skillBallr(_ style: SkillBallrFontStyle) -> Font {
        return style.font
    }
}

/// Font styles for consistent typography
enum SkillBallrFontStyle {
    case largeTitle
    case extraLargeTitle
    case headline
    case sectionTitle
    case cardTitle
    case body
    case bodyMedium
    case bodySecondary
    case button
    case buttonLarge
    case caption
    case captionSmall
    case textField
    case label
    case tabBar
    case navigationTitle
    
    var font: Font {
        switch self {
        case .largeTitle: return SkillBallrTypography.largeTitle
        case .extraLargeTitle: return SkillBallrTypography.extraLargeTitle
        case .headline: return SkillBallrTypography.headline
        case .sectionTitle: return SkillBallrTypography.sectionTitle
        case .cardTitle: return SkillBallrTypography.cardTitle
        case .body: return SkillBallrTypography.body
        case .bodyMedium: return SkillBallrTypography.bodyMedium
        case .bodySecondary: return SkillBallrTypography.bodySecondary
        case .button: return SkillBallrTypography.button
        case .buttonLarge: return SkillBallrTypography.buttonLarge
        case .caption: return SkillBallrTypography.caption
        case .captionSmall: return SkillBallrTypography.captionSmall
        case .textField: return SkillBallrTypography.textField
        case .label: return SkillBallrTypography.label
        case .tabBar: return SkillBallrTypography.tabBar
        case .navigationTitle: return SkillBallrTypography.navigationTitle
        }
    }
}
