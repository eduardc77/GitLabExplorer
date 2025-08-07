import Foundation

/// Lightweight project model for lists, search results, discovery
public struct ProjectSummary: Sendable, Codable, Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let nameWithOwner: String
    public let description: String?
    public let starCount: Int
    public let forkCount: Int
    public let language: String?
    public let owner: ProjectOwner
    public let updatedAt: Date
    public let avatarURL: URL?
    public let webURL: URL
    
    public init(
        id: String,
        name: String,
        nameWithOwner: String,
        description: String?,
        starCount: Int,
        forkCount: Int,
        language: String?,
        owner: ProjectOwner,
        updatedAt: Date,
        avatarURL: URL?,
        webURL: URL
    ) {
        self.id = id
        self.name = name
        self.nameWithOwner = nameWithOwner
        self.description = description
        self.starCount = starCount
        self.forkCount = forkCount
        self.language = language
        self.owner = owner
        self.updatedAt = updatedAt
        self.avatarURL = avatarURL
        self.webURL = webURL
    }
}
