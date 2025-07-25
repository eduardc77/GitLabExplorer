import Foundation
import UserNotifications

@MainActor
@Observable
final class LocalNotificationService {
    private let center = UNUserNotificationCenter.current()
    
    init() {
        center.delegate = LocalNotificationHandler.shared
    }
    
    /// Request notification permissions
    func requestPermissions() async -> Bool {
        do {
            return try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            return false
        }
    }
    
    /// Update app icon badge count
    func updateBadgeCount(_ count: Int) async {
        try? await center.setBadgeCount(count)
    }
    
    /// Send local notification for new GitLab notifications
    func sendNewNotificationsAlert(count: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "New GitLab Notifications"
        content.body = count == 1 ? "You have 1 new notification" : "You have \(count) new notifications"
        content.badge = NSNumber(value: count)
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "new-notifications",
            content: content,
            trigger: nil // Immediate
        )
        
        try? await center.add(request)
    }
}

final class LocalNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationHandler()
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification taps and actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - could navigate to notifications view
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User tapped the notification
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToNotifications"), object: nil)
        }
        completionHandler()
    }
} 
