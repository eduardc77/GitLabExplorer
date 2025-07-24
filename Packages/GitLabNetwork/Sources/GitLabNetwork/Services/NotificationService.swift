import Foundation
@preconcurrency import Apollo

/// Service for notification-related GitLab operations
/// This is a pure business logic service - UI state belongs in app-layer stores
public final class NotificationService: Sendable {
    
    // MARK: - Properties
    
    private let graphQLClient: GraphQLClient
    private let authService: AuthenticationService
    
    // MARK: - Initialization
    
    /// Initialize with existing dependencies (auth required for notifications)
    public init(graphQLClient: GraphQLClient, authService: AuthenticationService) {
        self.graphQLClient = graphQLClient
        self.authService = authService
    }
    
    // MARK: - Notification Operations
    
    /// Get user's todos (notifications) with optional filtering
    public func getTodos(
        first: Int = 20, 
        after: String? = nil,
        state: [TodoStateEnum]? = nil
    ) async throws -> TodosResult {
        guard await authService.isAuthenticated else {
            throw GitLabError.authenticationRequired
        }
        
        let query = GitLabAPI.GetTodosQuery(
            first: .some(first),
            after: after.map { .some($0) } ?? .none,
            state: state.map { stateArray in 
                .some(stateArray.map { .case($0.graphQLValue) })
            } ?? .none
        )
        
        let result = try await graphQLClient.executeQuery(query)
        
        guard let todosConnection = result.data?.currentUser?.todos else {
            return TodosResult(notifications: [], pageInfo: PageInfo(hasNextPage: false, endCursor: nil))
        }
        
        let notifications = todosConnection.edges?.compactMap { edge -> GitLabNotification? in
            guard let node = edge?.node else { return nil }
            return GitLabNotification.from(node)
        } ?? []
        
        let pageInfo = PageInfo(
            hasNextPage: todosConnection.pageInfo.hasNextPage,
            endCursor: todosConnection.pageInfo.endCursor
        )
        
        return TodosResult(notifications: notifications, pageInfo: pageInfo)
    }
    
    /// Mark a todo as done
    public func markTodoAsDone(id: String) async throws -> Bool {
        guard await authService.isAuthenticated else {
            throw GitLabError.authenticationRequired
        }
        
        // Create TodoID from string
        let todoId = GitLabAPI.TodoID(id)
        let mutation = GitLabAPI.TodoMarkDoneMutation(id: todoId)
        
        let result = try await graphQLClient.executeMutation(mutation)
        
        if let errors = result.data?.todoMarkDone?.errors, !errors.isEmpty {
            let errorMessage = errors.joined(separator: ", ")
            throw GitLabError.operationFailed("Failed to mark todo as done: \(errorMessage)")
        }
        
        return result.data?.todoMarkDone?.todo.state == .case(.done)
    }
    
    /// Get pending todos count
    public func getPendingTodosCount() async throws -> Int {
        let result = try await getTodos(first: 1, state: [.pending])
        // Note: This is a simplified count - in reality you'd want a separate count query
        // But GitLab API doesn't expose a direct count, so we'd need to paginate through all
        return result.notifications.count
    }
}

// MARK: - Result Types

/// Result wrapper for todos pagination
public struct TodosResult: Sendable {
    public let notifications: [GitLabNotification]
    public let pageInfo: PageInfo
    
    public init(notifications: [GitLabNotification], pageInfo: PageInfo) {
        self.notifications = notifications
        self.pageInfo = pageInfo
    }
}

/// Page info for pagination
public struct PageInfo: Sendable {
    public let hasNextPage: Bool
    public let endCursor: String?
    
    public init(hasNextPage: Bool, endCursor: String?) {
        self.hasNextPage = hasNextPage
        self.endCursor = endCursor
    }
}

// MARK: - Domain Model Conversion

extension GitLabNotification {
    /// Convert from Apollo GraphQL type to domain model
    static func from(_ todo: GitLabAPI.GetTodosQuery.Data.CurrentUser.Todos.Edge.Node) -> GitLabNotification? {
        
        // Convert target
        let target: TodoTarget?
        if let targetData = todo.targetEntity {
            if let issue = targetData.asIssue {
                let author = GitLabUser(
                    id: issue.issueAuthor.id,
                    username: issue.issueAuthor.username,
                    name: issue.issueAuthor.name,
                    email: nil,
                    avatarUrl: issue.issueAuthor.avatarUrl.flatMap(URL.init),
                    bio: nil,
                    location: nil,
                    webUrl: nil,
                    createdAt: nil,
                    lastActivityOn: nil,
                    state: .active
                )
                target = TodoTarget(
                    id: issue.id,
                    title: issue.title,
                    webUrl: issue.issueWebUrl,
                    author: author
                )
            } else if let mergeRequest = targetData.asMergeRequest {
            let author = mergeRequest.mergeRequestAuthor.map { authorData in
                GitLabUser(
                    id: authorData.id,
                    username: authorData.username,
                    name: authorData.name,
                    email: nil,
                    avatarUrl: authorData.avatarUrl.flatMap(URL.init),
                    bio: nil,
                    location: nil,
                    webUrl: nil,
                    createdAt: nil,
                    lastActivityOn: nil,
                    state: .active
                )
            }
                            target = TodoTarget(
                    id: mergeRequest.id,
                    title: mergeRequest.title,
                    webUrl: mergeRequest.mergeRequestWebUrl ?? "",
                    author: author
                )
            } else {
                target = nil
            }
        } else {
            target = nil
        }
        
        // Convert project
        let project = todo.project.map { projectData in
            TodoProject(
                id: projectData.id,
                name: projectData.name,
                fullPath: projectData.fullPath,
                webUrl: projectData.avatarUrl ?? ""
            )
        }
        
        // Convert author
        let author = GitLabUser(
            id: todo.author.id,
            username: todo.author.username,
            name: todo.author.name,
            email: nil,
            avatarUrl: todo.author.avatarUrl.flatMap(URL.init),
            bio: nil,
            location: nil,
            webUrl: nil,
            createdAt: nil,
            lastActivityOn: nil,
            state: .active
        )
        
        return GitLabNotification(
            id: todo.id,
            body: todo.body,
            state: TodoState(rawValue: todo.state.rawValue) ?? .pending,
            createdAt: ISO8601DateFormatter().date(from: todo.createdAt) ?? Date(),
            updatedAt: nil, // GitLab todos don't have updatedAt
            action: TodoActionType(rawValue: todo.action.rawValue) ?? .assigned,
            targetType: todo.targetType.rawValue,
            target: target,
            project: project,
            author: author
        )
    }
}

// MARK: - Public State Enum (for external use)

/// Todo state enum for public API
public enum TodoStateEnum: String, Sendable, CaseIterable {
    case pending = "pending"
    case done = "done"
    
    /// Convert to GraphQL enum
    var graphQLValue: GitLabAPI.TodoStateEnum {
        switch self {
        case .pending: return .pending
        case .done: return .done
        }
    }
} 
 