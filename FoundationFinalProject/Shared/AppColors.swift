import SwiftUI

extension Color {
    static let quizBackground = Color(hex: 0xF8F9FA)
    static let quizBlue = Color(hex: 0x0F3B4C)
    static let quizOption = Color(hex: 0x527A8A)
    static let quizGray = Color(hex: 0xA0AAB2)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
