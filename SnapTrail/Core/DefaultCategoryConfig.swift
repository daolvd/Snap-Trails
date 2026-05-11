import Foundation

struct DefaultCategoryConfig: Codable {
    let name: String
    let iconName: String
    let colorName: String   // stored as hex string e.g. "#4DA8FF"

    static let defaults: [DefaultCategoryConfig] = [
        DefaultCategoryConfig(name: "Study",      iconName: "book.fill",    colorName: "#4DA8FF"),
        DefaultCategoryConfig(name: "Food",        iconName: "fork.knife",   colorName: "#FF9433"),
        DefaultCategoryConfig(name: "Travel",      iconName: "airplane",     colorName: "#2ECC70"),
        DefaultCategoryConfig(name: "Daily Life",  iconName: "sun.max.fill", colorName: "#FFD700"),
    ]

    static func load() -> [DefaultCategoryConfig] {
        guard let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "json") else {
            return defaults
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([DefaultCategoryConfig].self, from: data)
        } catch {
            AppLog.error(
                "Failed to load DefaultCategories.json, falling back to built-in defaults",
                category: .data,
                error: error
            )
            return defaults
        }
    }
}
