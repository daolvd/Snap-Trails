import Foundation

enum DateFormatterHelper {
    static func displayDateTime(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    static func displayDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    static func displayTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
