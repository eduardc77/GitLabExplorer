import Foundation

/// Represents a GitLab project in the application domain
public struct GitLabProject: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let path: String
    public let fullPath: String
    public let description: String?
    public let visibility: ProjectVisibility
    public let avatarUrl: URL?
    public let webUrl: URL
    public let starCount: Int
    public let forkCount: Int
    public let lastActivityAt: Date?
    public let createdAt: Date
    public let updatedAt: Date
    public let repository: Repository?
    public let namespace: Namespace?
    
    public init(
        id: String, 
        name: String, 
        path: String,
        fullPath: String,
        description: String? = nil,
        visibility: ProjectVisibility,
        avatarUrl: URL? = nil,
        webUrl: URL,
        starCount: Int = 0,
        forkCount: Int = 0,
        lastActivityAt: Date? = nil,
        createdAt: Date,
        updatedAt: Date,
        repository: Repository? = nil,
        namespace: Namespace? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.fullPath = fullPath
        self.description = description
        self.visibility = visibility
        self.avatarUrl = avatarUrl
        self.webUrl = webUrl
        self.starCount = starCount
        self.forkCount = forkCount
        self.lastActivityAt = lastActivityAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.repository = repository
        self.namespace = namespace
    }
}

/// GitLab project visibility levels
public enum ProjectVisibility: String, Sendable, Codable, CaseIterable {
    case `private`
    case `internal`
    case `public`
}

/// GitLab project repository information
public struct Repository: Sendable, Codable, Equatable {
    public let rootRef: String?
    public let empty: Bool
    
    public init(rootRef: String? = nil, empty: Bool = true) {
        self.rootRef = rootRef
        self.empty = empty
    }
}

/// GitLab namespace (group or user) information
public struct Namespace: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let path: String
    public let fullPath: String
    
    public init(id: String, name: String, path: String, fullPath: String) {
        self.id = id
        self.name = name
        self.path = path
        self.fullPath = fullPath
    }
} 
