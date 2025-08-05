public struct ProjectStatistics: Sendable, Codable, Equatable {
    public let commitCount: Int
    public let storageSize: Int
    public let repositorySize: Int
    public let lfsObjectsSize: Int
    
    public init(
        commitCount: Int,
        storageSize: Int,
        repositorySize: Int,
        lfsObjectsSize: Int
    ) {
        self.commitCount = commitCount
        self.storageSize = storageSize
        self.repositorySize = repositorySize
        self.lfsObjectsSize = lfsObjectsSize
    }
}
