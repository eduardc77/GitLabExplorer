import Foundation

/// Result type for paginated projects
public struct ProjectsResult: Sendable {
    public let projects: [GitLabProject]
    public let pageInfo: PageInfo
    
    public init(projects: [GitLabProject], pageInfo: PageInfo) {
        self.projects = projects
        self.pageInfo = pageInfo
    }
}

/// Service for project-related GitLab operations
/// This is a pure business logic service - UI state belongs in app-layer stores
public final class ProjectService: Sendable {
    
    // MARK: - Properties
    
    private let graphQLClient: GraphQLClient
    private let authService: AuthenticationService?
    
    // MARK: - Initialization
    
    /// Initialize with existing dependencies
    public init(graphQLClient: GraphQLClient, authService: AuthenticationService? = nil) {
        self.graphQLClient = graphQLClient
        self.authService = authService
    }
    
    // MARK: - Project Operations
    
    /// Get public projects with pagination (no authentication required)
    public func getProjects(
        first: Int = 20,
        after: String? = nil
    ) async throws -> ProjectsResult {
        
        
        let mockProjects = [
            GitLabProject(
                id: "1",
                name: "GitLab Community Edition",
                path: "gitlab-ce",
                fullPath: "gitlab-org/gitlab-ce",
                description: "GitLab Community Edition",
                visibility: .public,
                webUrl: URL(string: "https://gitlab.com/gitlab-org/gitlab-ce")!,
                starCount: 23700,
                forkCount: 5600,
                lastActivityAt: Date(),
                createdAt: Date(),
                updatedAt: Date()
            ),
            GitLabProject(
                id: "2", 
                name: "GitLab Runner",
                path: "gitlab-runner",
                fullPath: "gitlab-org/gitlab-runner",
                description: "GitLab CI Multi Runner",
                visibility: .public,
                webUrl: URL(string: "https://gitlab.com/gitlab-org/gitlab-runner")!,
                starCount: 3400,
                forkCount: 890,
                lastActivityAt: Date(),
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        return ProjectsResult(
            projects: mockProjects,
            pageInfo: PageInfo(hasNextPage: true, endCursor: "cursor_2")
        )
    }
    
    /// Get user's projects (requires authentication)
    public func getUserProjects(userId: String) async throws -> [GitLabProject] {
        // Check authentication if auth service is available
        if let authService = authService {
            guard await authService.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create UserProjects.graphql query
        throw GitLabError.invalidConfiguration("UserProjects query not created yet. Add UserProjects.graphql operation.")
    }
    
    /// Search projects
    public func searchProjects(query: String, limit: Int = 20) async throws -> [GitLabProject] {
        // Check authentication if auth service is available
        if let authService = authService {
            guard await authService.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create SearchProjects.graphql query
        throw GitLabError.invalidConfiguration("SearchProjects query not implemented yet")
    }
    
    /// Get project by ID
    public func getProject(id: String) async throws -> GitLabProject? {
        // Check authentication if auth service is available
        if let authService = authService {
            guard await authService.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create GetProject.graphql query
        throw GitLabError.invalidConfiguration("GetProject query not implemented yet")
    }
} 
 