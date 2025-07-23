import Foundation

/// Represents a GitLab notification in the application domain
public struct GitLabNotification: Sendable, Codable, Identifiable {
    public let id: String
    public let title: String
    public let message: String
    public let type: GitLabNotificationType
    public let timestamp: Date
    public let isRead: Bool
    
    public init(
        id: String, 
        title: String, 
        message: String, 
        type: GitLabNotificationType, 
        timestamp: Date,
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

/// Types of GitLab notifications
public enum GitLabNotificationType: String, Sendable, Codable, CaseIterable {
    case general = "general"
    case mention = "mention"
    case mergeRequest = "merge_request"
    case issue = "issue"
    case pipeline = "pipeline"
    case deployment = "deployment"
    case approval = "approval"
} 
