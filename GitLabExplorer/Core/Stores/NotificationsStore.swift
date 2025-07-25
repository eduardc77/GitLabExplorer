//
//  NotificationsStore.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import GitLabNetwork

/// Main store for managing notification state in the UI layer
/// Follows the same pattern as AuthenticationStore for consistency
@MainActor
@Observable
final class NotificationsStore {
    
    // MARK: - Published State
    
    /// Current notifications
    public private(set) var notifications: [GitLabNotification] = []
    
    /// Loading state
    public private(set) var isLoading = false
    
    /// Error state
    public private(set) var error: GitLabError?
    
    /// Pagination info
    public private(set) var hasNextPage = false
    public private(set) var endCursor: String?
    
    /// Filter state
    public private(set) var currentFilter: NotificationFilter = .all
    
    /// Unread count (pending todos)
    public private(set) var unreadCount = 0
    
    // MARK: - Dependencies
    
    private let notificationService: NotificationService
    private let authStore: AuthenticationStore
    
    // MARK: - Initialization
    
    init(notificationService: NotificationService, authStore: AuthenticationStore) {
        self.notificationService = notificationService
        self.authStore = authStore
        
        // Start observing authentication changes
        observeAuthenticationChanges()
    }

    /// Convenience initializer for SwiftUI previews
    convenience init() {
        let authStore = AuthenticationStore()
        
        // Use preview configuration
        let configuration = GitLabConfiguration.preview()
        
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        let notificationService = NotificationService(graphQLClient: graphQLClient, authService: authService)
        
        self.init(notificationService: notificationService, authStore: authStore)
    }
    
    // MARK: - Public Actions
    
    /// Load notifications with current filter
    func loadNotifications(refresh: Bool = false) async {
        guard authStore.isAuthenticated else {
            notifications = []
            unreadCount = 0
            return
        }
        
        if refresh {
            notifications = []
            endCursor = nil
            hasNextPage = false
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await notificationService.getTodos(
                first: 20,
                after: endCursor,
                state: currentFilter.stateFilter
            )
            
            if refresh {
                notifications = result.notifications
            } else {
                notifications.append(contentsOf: result.notifications)
            }
            
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
            // Update unread count
            unreadCount = notifications.filter { $0.isUnread }.count
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    /// Load more notifications (pagination)
    func loadMoreNotifications() async {
        guard hasNextPage && !isLoading else { return }
        await loadNotifications(refresh: false)
    }
    
    /// Mark a notification as done
    func markAsDone(_ notification: GitLabNotification) async {
        do {
            let success = try await notificationService.markTodoAsDone(id: notification.id)
            
            if success {
                // Update local state
                if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                    var updatedNotification = notifications[index]
                    updatedNotification = GitLabNotification(
                        id: updatedNotification.id,
                        body: updatedNotification.body,
                        state: .done,
                        createdAt: updatedNotification.createdAt,
                        updatedAt: updatedNotification.updatedAt,
                        action: updatedNotification.action,
                        targetType: updatedNotification.targetType,
                        target: updatedNotification.target,
                        project: updatedNotification.project,
                        author: updatedNotification.author
                    )
                    notifications[index] = updatedNotification
                    
                    // Update unread count
                    unreadCount = notifications.filter { $0.isUnread }.count
                }
            }
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
    }
    
    /// Change notification filter
    func changeFilter(to filter: NotificationFilter) async {
        guard filter != currentFilter else { return }
        
        currentFilter = filter
        await loadNotifications(refresh: true)
    }
    
    /// Refresh notifications
    func refresh() async {
        await loadNotifications(refresh: true)
    }
    
    /// Clear error
    func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func observeAuthenticationChanges() {
        // Note: In a real implementation, you'd observe AuthenticationStore changes
        // For now, we'll rely on manual calls to loadNotifications when needed
        Task {
            if authStore.isAuthenticated {
                await loadNotifications(refresh: true)
            }
        }
    }
}

// MARK: - Supporting Types

/// Notification filter options
enum NotificationFilter: String, CaseIterable, Sendable {
    case all = "all"
    case pending = "pending"
    case done = "done"
    
    public var displayName: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .done: return "Done"
        }
    }
    
    var stateFilter: [TodoStateEnum]? {
        switch self {
        case .all: return nil
        case .pending: return [.pending]
        case .done: return [.done]
        }
    }
}

// MARK: - Computed Properties

extension NotificationsStore {
    /// Whether there are any notifications
    var hasNotifications: Bool {
        !notifications.isEmpty
    }
    
    /// Whether we're in an empty state (not loading and no notifications)
    var isEmpty: Bool {
        !isLoading && notifications.isEmpty
    }
    
    /// Current notifications filtered by search or other criteria
    var displayedNotifications: [GitLabNotification] {
        notifications
    }
} 
