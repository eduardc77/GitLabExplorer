public struct ProjectDiscoveryData: Sendable {
    public let trending: [ProjectSummary]
    public let mostStarred: [ProjectSummary]
    public let active: [ProjectSummary]
    
    public init(
        trending: [ProjectSummary],
        mostStarred: [ProjectSummary],
        active: [ProjectSummary]
    ) {
        self.trending = trending
        self.mostStarred = mostStarred
        self.active = active
    }
}
