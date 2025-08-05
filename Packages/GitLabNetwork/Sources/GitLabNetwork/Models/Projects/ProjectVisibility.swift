/// GitLab project visibility levels
public enum ProjectVisibility: String, Sendable, Codable, CaseIterable {
    case `private`
    case `internal`
    case `public`
}
