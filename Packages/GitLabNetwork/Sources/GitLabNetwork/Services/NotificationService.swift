/// Service for GitLab notification and real-time subscription management
/// This is a pure business logic service - UI state belongs in ViewModels
public final class NotificationService: Sendable {
    
    // MARK: - Properties
    
    private let graphQLClient: GraphQLClient
    private let authManager: AuthenticationManager?
    
    // MARK: - Initialization
    
    /// Initialize with existing dependencies
    public init(graphQLClient: GraphQLClient, authManager: AuthenticationManager? = nil) {
        self.graphQLClient = graphQLClient
        self.authManager = authManager
    }
    
    /// Convenience initializer - creates its own dependencies
    public convenience init(configuration: GitLabConfiguration, authManager: AuthenticationManager? = nil) {
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let apolloClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        self.init(graphQLClient: apolloClient, authManager: authManager)
    }
    
    // MARK: - Notification Operations
    
    /// Subscribe to real-time notifications
    public func subscribeToNotifications() async -> AsyncThrowingStream<GitLabNotification, Error> {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                return AsyncThrowingStream { continuation in
                    continuation.finish(throwing: GitLabError.authenticationRequired)
                }
            }
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                // For now, fail with helpful message:
                continuation.finish(throwing: GitLabError.invalidConfiguration("""
                Subscriptions not implemented yet. Create Notifications.graphql subscription and add:
                1. subscription NotificationsSubscription { ... }
                2. Use graphQLClient.subscribe(NotificationsSubscription())
                """))
            }
        }
    }
    
    /// Get user notifications
    public func getNotifications(limit: Int = 50) async throws -> [GitLabNotification] {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create GetNotifications.graphql query
        throw GitLabError.invalidConfiguration("GetNotifications query not implemented yet")
    }
    
    /// Mark notification as read
    public func markAsRead(notificationId: String) async throws {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create MarkNotificationRead.graphql mutation
        throw GitLabError.invalidConfiguration("MarkNotificationRead mutation not implemented yet")
    }
} 
