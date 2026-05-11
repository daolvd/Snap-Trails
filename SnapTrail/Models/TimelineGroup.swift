import Foundation

struct TimelineDayGroup: Identifiable, Hashable {
    let id: String
    let date: Date
    let memories: [Memory]

    static func == (lhs: TimelineDayGroup, rhs: TimelineDayGroup) -> Bool {
        lhs.id == rhs.id && lhs.memories.map(\.id) == rhs.memories.map(\.id)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TimelineMonthGroup: Identifiable, Hashable {
    let id: String
    let date: Date
    let days: [TimelineDayGroup]

    var memoryCount: Int { days.reduce(0) { $0 + $1.memories.count } }

    static func == (lhs: TimelineMonthGroup, rhs: TimelineMonthGroup) -> Bool {
        lhs.id == rhs.id && lhs.days == rhs.days
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TimelineYearGroup: Identifiable, Hashable {
    let id: Int
    let year: Int
    let months: [TimelineMonthGroup]

    var memoryCount: Int { months.reduce(0) { $0 + $1.memoryCount } }

    static func == (lhs: TimelineYearGroup, rhs: TimelineYearGroup) -> Bool {
        lhs.id == rhs.id && lhs.months == rhs.months
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
