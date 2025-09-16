import SwiftUI

/// SkillBallr Design System - Color Palette
/// Based on the MVP Blueprint specifications
struct SkillBallrColors {
    
    // MARK: - Primary Brand Colors
    /// Skill Blue - Primary brand color (#1E3A8A)
    static let skillBlue = Color(red: 0.118, green: 0.227, blue: 0.541)
    
    /// Skill Orange - Secondary brand color (#F97316)
    static let skillOrange = Color(red: 0.976, green: 0.451, blue: 0.086)
    
    // MARK: - Dark Theme Colors
    /// Dark Gray - Card backgrounds (#1F2937)
    static let darkGray = Color(red: 0.122, green: 0.161, blue: 0.216)
    
    /// Light Gray - Text on dark backgrounds (#D1D5DB)
    static let lightGray = Color(red: 0.820, green: 0.839, blue: 0.859)
    
    /// Very Dark Blue-Grey - Background gradients
    static let veryDarkBlue = Color(red: 0.05, green: 0.08, blue: 0.15)
    
    /// Slightly Lighter Center - Gradient middle
    static let lighterCenter = Color(red: 0.08, green: 0.12, blue: 0.18)
    
    // MARK: - Semantic Colors
    /// Success Green
    static let success = Color.green
    
    /// Error Red
    static let error = Color.red
    
    /// Warning Yellow
    static let warning = Color.yellow
    
    /// Info Blue
    static let info = skillBlue
    
    // MARK: - Background Colors
    /// Primary Background
    static let background = veryDarkBlue
    
    /// Card Background
    static let cardBackground = Color.black.opacity(0.3)
    
    /// Overlay Background
    static let overlayBackground = Color.black.opacity(0.4)
}

// MARK: - Color Extensions
extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
