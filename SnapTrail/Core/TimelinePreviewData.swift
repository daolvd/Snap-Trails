#if DEBUG
import Foundation

@MainActor
enum TimelinePreviewData {
    static var memories: [Memory] {
        let now = Date()
        let cal = Calendar.current
        return [
            Memory(imageFileName: "preview-1.jpg", locationName: "UTS Building 11",
                   latitude: -33.88, longitude: 151.20, dateTime: now,
                   caption: "Today", isFavourite: true),
            Memory(imageFileName: "preview-2.jpg", locationName: "Central Station",
                   latitude: -33.88, longitude: 151.20,
                   dateTime: cal.date(byAdding: .day, value: -1, to: now)!,
                   caption: "Yesterday"),
            Memory(imageFileName: "preview-3.jpg", locationName: "Darling Harbour",
                   latitude: -33.87, longitude: 151.20,
                   dateTime: cal.date(byAdding: .day, value: -3, to: now)!,
                   caption: "Earlier this week", isFavourite: true),
            Memory(imageFileName: "preview-4.jpg", locationName: "Bondi Beach",
                   latitude: -33.89, longitude: 151.27,
                   dateTime: cal.date(byAdding: .month, value: -1, to: now)!,
                   caption: "Last month"),
            Memory(imageFileName: "preview-5.jpg", locationName: "Blue Mountains",
                   latitude: -33.71, longitude: 150.31,
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
