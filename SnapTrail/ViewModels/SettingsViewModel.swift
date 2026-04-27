import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDailyReminderEnabled: Bool
    @Published var errorMessage: String?

    init() {
        self.isDailyReminderEnabled = UserDefaults.standard.bool(
            forKey: AppConstants.isDailyReminderEnabledKey
        )
    }

    func toggleDailyReminder() {
        isDailyReminderEnabled.toggle()

        UserDefaults.standard.set(
            isDailyReminderEnabled,
            forKey: AppConstants.isDailyReminderEnabledKey
        )

        if isDailyReminderEnabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    NotificationService.shared.scheduleDailyReminder()
                } else {
                    isDailyReminderEnabled = false
                    UserDefaults.standard.set(false, forKey: AppConstants.isDailyReminderEnabledKey)
                    errorMessage = AppError.permissionDenied.localizedDescription
                }
            }
        } else {
            NotificationService.shared.cancelReminder()
        }
    }
}
