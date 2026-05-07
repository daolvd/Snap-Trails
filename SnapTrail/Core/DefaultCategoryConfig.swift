import Foundation

struct DefaultCategoryConfig: Codable {
    let name: String
    let iconName: String
    let colorName: String

    static let defaults: [DefaultCategoryConfig] = [
        DefaultCategoryConfig(name: "Study",      iconName: "book.fill",    colorName: "blue"),
        DefaultCategoryConfig(name: "Food",        iconName: "fork.knife",   colorName: "orange"),
        DefaultCategoryConfig(name: "Travel",      iconName: "airplane",     colorName: "green"),
        DefaultCategoryConfig(name: "Daily Life",  iconName: "sun.max.fill", colorName: "yellow"),
    ]

    static func load() -> [DefaultCategoryConfig] {
        guard let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let configs = try? JSONDecoder().decode([DefaultCategoryConfig].self, from: data)
        else {
            return defaults
        }
        return configs
    }
}
