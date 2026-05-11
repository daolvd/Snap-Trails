import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    func scheduleDailyReminder(hour: Int, minute: Int)
    func cancelReminder()
}

extension NotificationServiceProtocol {
    func scheduleDailyReminder() {
        scheduleDailyReminder(
            hour: AppConstants.defaultReminderHour,
            minute: AppConstants.defaultReminderMinute
        )
    }
}

final class NotificationService: NotificationServiceProtocol {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
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
        center.removePendingNotificationRequests(
            withIdentifiers: [AppConstants.dailyReminderIdentifier]
        )
    }
}
