import Foundation

protocol CategoryDataServiceProtocol {
    func fetchAll() throws -> [MemoryCategory]
    func create(name: String, iconName: String, colorName: String) throws
    func update(_ category: MemoryCategory, name: String, iconName: String, colorName: String) throws
    func delete(_ category: MemoryCategory) throws
}

extension CategoryDataService: CategoryDataServiceProtocol {}
