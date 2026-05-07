import Foundation

enum TimelineDisplayMode: String, CaseIterable, Identifiable {
    case day = "Days"
    case month = "Months"
    case year = "Years"
    var id: String { rawValue }
}
