import Foundation
import SwiftUI

enum CategoryIcon: String, CaseIterable, Identifiable {
    case tag       = "tag.fill"
    case travel    = "airplane"
    case food      = "fork.knife"
    case study     = "book.fill"
    case daily     = "sun.max.fill"
    case photo     = "camera.fill"
    case heart     = "heart.fill"
    case location  = "mappin.circle.fill"
    case star      = "star.fill"
    case music     = "music.note"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tag:      return "Tag"
        case .travel:   return "Travel"
        case .food:     return "Food"
        case .study:    return "Study"
        case .daily:    return "Daily"
        case .photo:    return "Photo"
        case .heart:    return "Heart"
        case .location: return "Location"
        case .star:     return "Star"
        case .music:    return "Music"
        }
    }
}

enum CategoryColor: String, CaseIterable, Identifiable {
    case green  = "green"
    case blue   = "blue"
    case orange = "orange"
    case yellow = "yellow"
    case red    = "red"
    case purple = "purple"
    case pink   = "pink"
    case teal   = "teal"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .green:  return Color(red: 0.18, green: 0.80, blue: 0.44)
        case .blue:   return Color(red: 0.20, green: 0.60, blue: 1.00)
        case .orange: return Color(red: 1.00, green:
