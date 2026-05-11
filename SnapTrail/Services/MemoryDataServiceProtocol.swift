import Foundation

protocol MemoryDataServiceProtocol {
    func fetchAll() throws -> [Memory]
    func fetchFavourites() throws -> [Memory]
    func search(
        keyword: String,
        category: MemoryCategory?,
        fromDate: Date?,
        toDate: Date?,
        favouriteOnly: Bool
    ) throws -> [Memory]
    func save(_ memory: Memory) throws
    func delete(_ memory: Memory) throws
    func setFavourite(_ memory: Memory, to value: Bool) throws
    func update(_ memory: Memory) throws
}

extension MemoryDataService: MemoryDataServiceProtocol {}
