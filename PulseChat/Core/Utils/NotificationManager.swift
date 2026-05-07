import Foundation
import UserNotifications

@MainActor
final class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            if AppConfig.isDebug {
                print("Notification auth error: \(error)")
            }
        }
    }

    func notifyNewMessage(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request)
    }
}
