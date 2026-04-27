import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleDailyReminder(
        hour: Int = AppConstants.defaultReminderHour,
        minute: Int = AppConstants.defaultReminderMinute
    ) {
        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(
            withIdentifiers: [AppConstants.dailyReminderIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "SnapTrail"
        content.body = "Capture one memory from today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: AppConstants.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [AppConstants.dailyReminderIdentifier]
            )
    }
}
