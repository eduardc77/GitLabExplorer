import Foundation

/// Represents a GitLab user in the application domain
public struct GitLabUser: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let username: String
    public let name: String
    public let email: String?
    public let avatarUrl: URL?
    public let bio: String?
    public let location: String?
    public let webUrl: URL?
    public let publicEmail: String?
    public let createdAt: Date?
    public let lastActivityOn: Date?
    public let state: UserState
    
    public init(
        id: String,
        username: String,
        name: String,
        email: String? = nil,
        avatarUrl: URL? = nil,
        bio: String? = nil,
        location: String? = nil,
        webUrl: URL? = nil,
        publicEmail: String? = nil,
        createdAt: Date? = nil,
        lastActivityOn: Date? = nil,
        state: UserState = .active
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.location = location
        self.webUrl = webUrl
        self.publicEmail = publicEmail
        self.createdAt = createdAt
        self.lastActivityOn = lastActivityOn
        self.state = state
    }
}

/// GitLab user account states
public enum UserState: String, Sendable, Codable, CaseIterable {
    case active
    case blocked
    case deactivated
}

// MARK: - Apollo GraphQL Conversion Extensions

extension GitLabUser {
    /// Convert Apollo's UserDetails fragment to domain model
    static func from(_ userDetails: GitLabAPI.UserDetails) -> GitLabUser {
        GitLabUser(
            id: userDetails.id,
            username: userDetails.username,
            name: userDetails.name,
            email: userDetails.publicEmail,
            avatarUrl: userDetails.avatarUrl != nil ? URL(string: userDetails.avatarUrl!) : nil
        )
    }
    
    /// Convert Apollo's CurrentUserQuery result to domain model
    static func from(_ apolloUser: GitLabAPI.CurrentUserQuery.Data.CurrentUser) -> GitLabUser {
        GitLabUser(
            id: apolloUser.id,
            username: apolloUser.username,
            name: apolloUser.name,
            email: apolloUser.publicEmail,
            avatarUrl: apolloUser.avatarUrl != nil ? URL(string: apolloUser.avatarUrl!) : nil
        )
    }
} 
