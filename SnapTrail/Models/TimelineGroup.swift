import Foundation

struct TimelineDayGroup: Identifiable {
    let id: String
    let date: Date
    let memories: [Memory]
}

struct TimelineMonthGroup: Identifiable {
    let id: String
    let date: Date
    let days: [TimelineDayGroup]

    var memoryCount: Int { days.reduce(0) { $0 + $1.memories.count } }
}

struct TimelineYearGroup: Identifiable {
    let id: Int
    let year: Int
    let months: [TimelineMonthGroup]

    var memoryCount: Int { months.reduce(0) { $0 + $1.memoryCount } }
}
