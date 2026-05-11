import Foundation
import OSLog

/// Centralised logging façade. All non-user-facing diagnostics flow through here
/// so we never silently swallow errors with empty `catch {}` blocks.
///
/// Usage:
///   AppLog.error("Failed to save", category: .data, error: error)
enum AppLog {
    enum Category: String {
        case app
        case data
        case storage
        case location
        case permissions
    }

    private static let subsystem = Bundle.main.bundleIdentifier ?? "SnapTrail"

    private static func logger(for category: Category) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    static func error(
        _ message: String,
        category: Category = .app,
        error: Error? = nil,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        let suffix = error.map { " — \(String(describing: $0))" } ?? ""
        logger(for: category).error("\(message)\(suffix) [\(file):\(line)]")
    }

    static func warning(_ message: String, category: Category = .app) {
        logger(for: category).warning("\(message)")
    }

    static func info(_ message: String, category: Category = .app) {
        logger(for: category).info("\(message)")
    }
}
