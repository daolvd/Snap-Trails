import SwiftUI

extension Color {
    static let snapBackground = Color.black
    static let snapCard = Color(red: 0.09, green: 0.09, blue: 0.09)
    static let snapCardLight = Color(red: 0.14, green: 0.14, blue: 0.14)
    static let snapAccent = Color(red: 0.68, green: 1.0, blue: 0.0)
    static let snapTextPrimary = Color.white
    static let snapTextSecondary = Color.gray

    // MARK: - Hex support for category colours

    /// Initialises a Color from a hex string such as "#AEFF00" or "AEFF00".
    /// Falls back to gray for malformed input.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else {
            self = .gray
            return
        }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Returns the color as a "#RRGGBB" hex string.
    var toHex: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
