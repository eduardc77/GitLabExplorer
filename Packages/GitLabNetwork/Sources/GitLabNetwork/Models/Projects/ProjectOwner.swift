import Foundation

public struct ProjectOwner: Sendable, Codable, Equatable, Hashable {
    public let login: String
    public let name: String?
    public let avatarURL: URL?
    public let type: OwnerType
    public let webURL: URL?
    
    public init(
        login: String,
        name: String?,
        avatarURL: URL?,
        type: OwnerType,
        webURL: URL?
    ) {
        self.login = login
        self.name = name
        self.avatarURL = avatarURL
        self.type = type
        self.webURL = webURL
    }
}
