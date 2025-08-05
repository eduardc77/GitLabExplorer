/// GitLab project repository information
public struct Repository: Sendable, Codable, Equatable {
    public let rootRef: String?
    public let empty: Bool
    
    public init(rootRef: String? = nil, empty: Bool = true) {
        self.rootRef = rootRef
        self.empty = empty
    }
}
