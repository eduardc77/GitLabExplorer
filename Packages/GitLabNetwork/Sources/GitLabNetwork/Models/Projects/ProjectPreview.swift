import Foundation

/// Medium-detail project model for cards, previews
public struct ProjectPreview: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let nameWithOwner: String
    public let description: String?
    public let starCount: Int
    public let forkCount: Int
    public let primaryLanguage: String?
    public let owner: ProjectOwner
    public let updatedAt: Date
    public let createdAt: Date
    public let avatarURL: URL?
    public let webURL: URL
    public let visibility: ProjectVisibility
    public let topics: [String]
    public let lastActivityAt: Date?
    
    public init(
        id: String,
        name: String,
        nameWithOwner: String,
        description: String?,
        starCount: Int,
        forkCount: Int,
        primaryLanguage: String?,
        owner: ProjectOwner,
        updatedAt: Date,
        createdAt: Date,
        avatarURL: URL?,
        webURL: URL,
        visibility: ProjectVisibility,
        topics: [String],
        lastActivityAt: Date?
    ) {
        self.id = id
        self.name = name
        self.nameWithOwner = nameWithOwner
        self.description = description
        self.starCount = starCount
        self.forkCount = forkCount
        self.primaryLanguage = primaryLanguage
        self.owner = owner
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.avatarURL = avatarURL
        self.webURL = webURL
        self.visibility = visibility
        self.topics = topics
        self.lastActivityAt = lastActivityAt
    }
}
