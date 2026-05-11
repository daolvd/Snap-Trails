#if DEBUG
import Foundation

@MainActor
enum TimelinePreviewData {
    static var memories: [Memory] {
        let now = Date()
        let cal = Calendar.current
        return [
            Memory(imageFileName: "preview-1.jpg",
                   location: GeoLocation(latitude: -33.88, longitude: 151.20, name: "UTS Building 11"),
                   dateTime: now,
                   caption: "Today", isFavourite: true),
            Memory(imageFileName: "preview-2.jpg",
                   location: GeoLocation(latitude: -33.88, longitude: 151.20, name: "Central Station"),
                   dateTime: cal.date(byAdding: .day, value: -1, to: now)!,
                   caption: "Yesterday"),
            Memory(imageFileName: "preview-3.jpg",
                   location: GeoLocation(latitude: -33.87, longitude: 151.20, name: "Darling Harbour"),
                   dateTime: cal.date(byAdding: .day, value: -3, to: now)!,
                   caption: "Earlier this week", isFavourite: true),
            Memory(imageFileName: "preview-4.jpg",
                   location: GeoLocation(latitude: -33.89, longitude: 151.27, name: "Bondi Beach"),
                   dateTime: cal.date(byAdding: .month, value: -1, to: now)!,
                   caption: "Last month"),
            Memory(imageFileName: "preview-5.jpg",
                   location: GeoLocation(latitude: -33.71, longitude: 150.31, name: "Blue Mountains"),
                   dateTime: cal.date(byAdding: .year, value: -1, to: now)!,
                   caption: "Last year")
        ]
    }

    static var dayGroup: TimelineDayGroup {
        TimelineDayGroup(id: "today", date: Date(), memories: Array(memories.prefix(2)))
    }

    static var monthGroup: TimelineMonthGroup {
        TimelineMonthGroup(
            id: "month",
            date: Date(),
            days: [
                dayGroup,
                TimelineDayGroup(
                    id: "yesterday",
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    memories: [memories[2]]
                )
            ]
        )
    }

    static var yearGroup: TimelineYearGroup {
        TimelineYearGroup(
            id: Calendar.current.component(.year, from: Date()),
            year: Calendar.current.component(.year, from: Date()),
            months: [monthGroup]
        )
    }

    static var yearGroups: [TimelineYearGroup] {
        let thisYear = Calendar.current.component(.year, from: Date())
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        return [
            yearGroup,
            TimelineYearGroup(
                id: thisYear - 1,
                year: thisYear - 1,
                months: [
                    TimelineMonthGroup(
                        id: "prev-month",
                        date: lastMonth,
                        days: [TimelineDayGroup(id: "old-day", date: lastYear, memories: [memories[3], memories[4]])]
                    )
                ]
            )
        ]
    }
}
#endif
