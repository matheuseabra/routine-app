import UserNotifications

protocol ReminderPermissionRequesting {
    func requestAuthorization() async -> Bool
}

struct ReminderPermissionService: ReminderPermissionRequesting {
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }
}

