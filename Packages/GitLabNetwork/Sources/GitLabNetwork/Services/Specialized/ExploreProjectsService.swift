import Foundation

// MARK: - Explore Projects Service Protocol
public protocol ExploreProjectsServiceProtocol: Sendable {
    func getTrendingProjects(limit: Int, after: String?) async throws -> ProjectsResult
    func getMostStarredProjects(limit: Int, after: String?) async throws -> ProjectsResult
    func getActiveProjects(limit: Int, after: String?) async throws -> ProjectsResult
}

// MARK: - Explore Projects Service
/// Handles project exploration operations using GraphQL API
/// Manages its own caching strategy optimized for exploration data
public final class ExploreProjectsService: ExploreProjectsServiceProtocol {
    
    // MARK: - Properties
    private let projectService: ProjectService
    
    // MARK: - Initialization
    public init(projectService: ProjectService) {
        self.projectService = projectService
    }
    
    /// Convenience initializer
    public convenience init(configuration: GitLabConfiguration, authProvider: GitLabAuthProvider) {
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let projectService = ProjectService(graphQLClient: graphQLClient)
        self.init(projectService: projectService)
    }
    
    // MARK: - Exploration Operations
    
    /// Get trending projects - sorted by recent activity
    public func getTrendingProjects(limit: Int = 20, after: String? = nil) async throws -> ProjectsResult {
        return try await projectService.getProjects(first: limit, after: after, sort: "latest_activity_desc")
    }
    
    /// Get most starred projects - sorted by star count
    public func getMostStarredProjects(limit: Int = 20, after: String? = nil) async throws -> ProjectsResult {
        return try await projectService.getProjects(first: limit, after: after, sort: "stars_desc")
    }
    
    /// Get active projects - projects with recent activity (last 30 days)
    public func getActiveProjects(limit: Int = 20, after: String? = nil) async throws -> ProjectsResult {
        return try await projectService.getProjects(first: limit, after: after, sort: "latest_activity_desc")
    }
    
    /// Get comprehensive exploration data in parallel
    public func getExplorationData(limit: Int = 10) async throws -> ProjectExplorationData {
        async let trending = getTrendingProjects(limit: limit, after: nil)
        async let starred = getMostStarredProjects(limit: limit, after: nil)
        async let active = getActiveProjects(limit: limit, after: nil)
        
        let results = try await (trending, starred, active)
        
        return ProjectExplorationData(
            trending: results.0.projects.map { $0.toSummary() },
            mostStarred: results.1.projects.map { $0.toSummary() },
            active: results.2.projects.map { $0.toSummary() }
        )
    }
} 