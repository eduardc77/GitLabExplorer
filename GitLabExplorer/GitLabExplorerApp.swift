//
//  GitLabExplorerApp.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork
import BackgroundTasks

@main
struct GitLabExplorerApp: App {
    @State private var authStore: AuthenticationStore
    @State private var notificationsStore: NotificationsStore
    @State private var projectsStore: ProjectsStore
    @State private var localNotificationService = LocalNotificationService()

    init() {
        // Create shared configuration from Info.plist (Apple's recommended approach)
        let configuration = GitLabConfiguration.fromInfoPlist()
        
        // Create shared dependencies - SINGLE INSTANCES
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        
        // Create services using shared dependencies
        let notificationService = NotificationService(graphQLClient: graphQLClient, authService: authService)
        let projectService = ProjectService(graphQLClient: graphQLClient, authService: authService)
        
        // Create stores with injected dependencies
        let authStore = AuthenticationStore(authService: authService, configuration: configuration)
        let notificationsStore = NotificationsStore(notificationService: notificationService, authStore: authStore)
        let projectsStore = ProjectsStore(projectService: projectService, authStore: authStore)

        self._authStore = State(initialValue: authStore)
        self._notificationsStore = State(initialValue: notificationsStore)
        self._projectsStore = State(initialValue: projectsStore)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
                .environment(notificationsStore)
                .environment(projectsStore)
                .environment(localNotificationService)
                .task {
                    // Check authentication state on app launch
                    await authStore.refreshAuthState()
                }
        }
        .backgroundTask(.appRefresh("com.gitlabexplorer.background-refresh")) {
            await performBackgroundSync()
        }
    }

    // MARK: - Background Sync

    @MainActor
    private func performBackgroundSync() async {
        guard authStore.isAuthenticated else { return }

        let previousCount = notificationsStore.unreadCount
        await notificationsStore.loadNotifications()
        let newCount = notificationsStore.unreadCount

        // Update badge and send notification if new items
        await localNotificationService.updateBadgeCount(newCount)
        if newCount > previousCount {
            await localNotificationService.sendNewNotificationsAlert(count: newCount - previousCount)
        }

        // Schedule next refresh
        let request = BGAppRefreshTaskRequest(identifier: "com.gitlabexplorer.background-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
        try? BGTaskScheduler.shared.submit(request)
    }
}
