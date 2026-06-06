import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.05, green: 0.45, blue: 0.48)
    static let accentSoft = Color(red: 0.05, green: 0.45, blue: 0.48).opacity(0.14)
    static let canvas = Color(nsColor: .windowBackgroundColor)
    static let sidebar = Color(nsColor: .underPageBackgroundColor)
    static let surface = Color(nsColor: .controlBackgroundColor)
    static let elevated = Color(nsColor: .textBackgroundColor)
    static let stroke = Color(nsColor: .separatorColor).opacity(0.7)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)
}

extension View {
    func quietCard(cornerRadius: CGFloat = 10) -> some View {
        self
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            }
    }
}
