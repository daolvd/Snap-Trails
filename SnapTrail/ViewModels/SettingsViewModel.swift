import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDailyReminderEnabled: Bool
    @Published var errorMessage: String?

    private let notificationService: NotificationServiceProtocol
    private let defaults: UserDefaults

    init(
        notificationService: NotificationServiceProtocol,
        defaults: UserDefaults = .standard
    ) {
        self.notificationService = notificationService
        self.defaults = defaults
        self.isDailyReminderEnabled = defaults.bool(forKey: AppConstants.isDailyReminderEnabledKey)
    }

    func toggleDailyReminder() {
        isDailyReminderEnabled.toggle()

        defaults.set(isDailyReminderEnabled, forKey: AppConstants.isDailyReminderEnabledKey)

        if isDailyReminderEnabled {
            Task {
                let granted = await notificationService.requestPermission()
                if granted {
                    notificationService.scheduleDailyReminder()
                } else {
                    isDailyReminderEnabled = false
                    defaults.set(false, forKey: AppConstants.isDailyReminderEnabledKey)
                    errorMessage = AppError.permissionDenied.localizedDescription
                }
            }
        } else {
            notificationService.cancelReminder()
        }
    }
}
