import Foundation

/// Represents a GitLab todo (notification) in the application domain
public struct GitLabNotification: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let body: String?
    public let state: TodoState
    public let createdAt: Date
    public let updatedAt: Date?
    public let action: TodoActionType
    public let targetType: String?
    public let target: TodoTarget?
    public let project: TodoProject?
    public let author: GitLabUser?
    
    public init(
        id: String,
        body: String?,
        state: TodoState,
        createdAt: Date,
        updatedAt: Date?,
        action: TodoActionType,
        targetType: String?,
        target: TodoTarget?,
        project: TodoProject?,
        author: GitLabUser?
    ) {
        self.id = id
        self.body = body
        self.state = state
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.action = action
        self.targetType = targetType
        self.target = target
        self.project = project
        self.author = author
    }
}

/// Todo state in GitLab
public enum TodoState: String, Sendable, Codable, CaseIterable {
    case pending
    case done
}

/// Types of todo actions in GitLab
public enum TodoActionType: String, Sendable, Codable, CaseIterable {
    case assigned
    case mentioned
    case buildFailed = "build_failed"
    case marked
    case approvalRequired = "approval_required"
    case unmergeable
    case directlyAddressed = "directly_addressed"
    case mergeTrainRemoved = "merge_train_removed"
}

/// Todo target (Issue, MergeRequest, etc.)
public struct TodoTarget: Sendable, Codable, Equatable {
    public let id: String
    public let title: String
    public let webUrl: String
    public let author: GitLabUser?
    
    public init(id: String, title: String, webUrl: String, author: GitLabUser?) {
        self.id = id
        self.title = title
        self.webUrl = webUrl
        self.author = author
    }
}

/// Project information for a todo
public struct TodoProject: Sendable, Codable, Equatable {
    public let id: String
    public let name: String
    public let fullPath: String
    public let webUrl: String
    
    public init(id: String, name: String, fullPath: String, webUrl: String) {
        self.id = id
        self.name = name
        self.fullPath = fullPath
        self.webUrl = webUrl
    }
}

// MARK: - Computed Properties

public extension GitLabNotification {
    /// Whether this todo is unread (pending)
    var isUnread: Bool {
        state == .pending
    }
    
    /// Human-readable title for the notification
    var displayTitle: String {
        if let target = target {
            return target.title
        }
        return body ?? "Notification"
    }
    
    /// Human-readable subtitle with action context
    var displaySubtitle: String {
        var components: [String] = []
        
        if let author = author {
            components.append("by \(author.name)")
        }
        
        if let project = project {
            components.append("in \(project.name)")
        }
        
        return components.joined(separator: " ")
    }
} 
