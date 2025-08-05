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
    public let forksCount: Int
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
        forksCount: Int = 0,
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
        self.forksCount = forksCount
        self.lastActivityAt = lastActivityAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.repository = repository
        self.namespace = namespace
    }
}

extension GitLabProject {
    /// Convert to lightweight ProjectSummary
    public func toSummary() -> ProjectSummary {
        return ProjectSummary(
            id: id,
            name: name,
            nameWithOwner: fullPath,
            description: description,
            starCount: starCount,
            forkCount: forksCount,
            language: nil, // Not available in GitLabProject
            owner: ProjectOwner(
                login: namespace?.path ?? "",
                name: namespace?.name,
                avatarURL: avatarUrl,
                type: .group, // GitLab uses groups/namespaces
                webURL: webUrl
            ),
            updatedAt: updatedAt,
            avatarURL: avatarUrl,
            webURL: webUrl
        )
    }

    /// Convert to medium-detail ProjectPreview
    public func toPreview() -> ProjectPreview {
        return ProjectPreview(
            id: id,
            name: name,
            nameWithOwner: fullPath,
            description: description,
            starCount: starCount,
            forkCount: forksCount,
            primaryLanguage: nil, // Not available in GitLabProject
            owner: ProjectOwner(
                login: namespace?.path ?? "",
                name: namespace?.name,
                avatarURL: avatarUrl,
                type: .group,
                webURL: webUrl
            ),
            updatedAt: updatedAt,
            createdAt: createdAt,
            avatarURL: avatarUrl,
            webURL: webUrl,
            visibility: visibility,
            topics: [], // Not available in basic GitLabProject
            lastActivityAt: lastActivityAt
        )
    }
}
