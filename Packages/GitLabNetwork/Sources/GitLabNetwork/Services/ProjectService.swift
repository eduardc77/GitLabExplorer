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

// MARK: - Apollo Time Extension

private extension GitLabAPI.Time {
    /// Convert Apollo Time (ISO 8601 string) to Date
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self) ?? {
            // Fallback without fractional seconds
            let fallbackFormatter = ISO8601DateFormatter()
            return fallbackFormatter.date(from: self)
        }()
    }
}

/// Service for project-related GitLab operations using GraphQL
/// This is a pure business logic service - UI state belongs in app-layer stores
/// For project discovery features (trending, starred), use ProjectDiscoveryService
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
        after: String? = nil,
        sort: String? = nil
    ) async throws -> ProjectsResult {
        
        // Create the Apollo query
        let query = GitLabAPI.GetProjectsQuery(
            first: .some(first),
            after: after.map { .some($0) } ?? .none,
            sort: sort.map { .some($0) } ?? .none
        )
        
        // Execute the query using the Sendable-compliant method
        return try await graphQLClient.executeQueryAndExtractData(query) { data in
            // Extract data immediately within the actor context
            guard let projectsConnection = data.projects else {
                throw GitLabError.invalidResponse("No projects data received")
            }
            
            // Map Apollo types to domain models within the same actor context
            let projects = self.mapApolloProjectsToDomain(projectsConnection.edges)
            let pageInfo = self.mapApolloPageInfoToDomain(projectsConnection.pageInfo)
            
            return ProjectsResult(projects: projects, pageInfo: pageInfo)
        }
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

// MARK: - Apollo to Domain Mapping

private extension ProjectService {
    
    /// Map Apollo projects to domain models
    func mapApolloProjectsToDomain(_ edges: [GitLabAPI.GetProjectsQuery.Data.Projects.Edge?]?) -> [GitLabProject] {
        guard let edges = edges else { return [] }
        
        return edges.compactMap { edge in
            guard let edge = edge,
                  let node = edge.node else { return nil }
            
            return mapApolloProjectNodeToDomain(node)
        }
    }
    
    /// Map individual Apollo project node to domain model
    func mapApolloProjectNodeToDomain(_ node: GitLabAPI.GetProjectsQuery.Data.Projects.Edge.Node) -> GitLabProject {
        
        // Map visibility
        let visibility: ProjectVisibility
        switch node.visibility?.lowercased() {
        case "private":
            visibility = .private
        case "internal":
            visibility = .internal
        case "public":
            visibility = .public
        default:
            visibility = .public // Default fallback
        }
        
        // Map repository
        let repository = node.repository.map { apolloRepo in
            Repository(
                rootRef: apolloRepo.rootRef,
                empty: apolloRepo.empty
            )
        }
        
        // Map namespace
        let namespace = node.namespace.map { apolloNamespace in
            Namespace(
                id: apolloNamespace.id, // GitLabAPI.ID is just a String typealias
                name: apolloNamespace.name,
                path: apolloNamespace.path,
                fullPath: apolloNamespace.fullPath // GitLabAPI.ID is just a String typealias
            )
        }
        
        // Convert dates
        let createdAt = node.createdAt?.date ?? Date()
        let updatedAt = node.updatedAt?.date ?? Date()
        let lastActivityAt = node.lastActivityAt?.date
        
        return GitLabProject(
            id: node.id, // GitLabAPI.ID is just a String typealias
            name: node.name,
            path: node.path,
            fullPath: node.fullPath, // GitLabAPI.ID is just a String typealias
            description: node.description,
            visibility: visibility,
            avatarUrl: node.avatarUrl.flatMap { URL(string: $0) },
            webUrl: node.webUrl.flatMap { URL(string: $0) } ?? URL(string: "https://gitlab.com")!,
            starCount: node.starCount,
            forksCount: node.forksCount,
            lastActivityAt: lastActivityAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            repository: repository,
            namespace: namespace
        )
    }
    
    /// Map Apollo page info to domain model
    func mapApolloPageInfoToDomain(_ pageInfo: GitLabAPI.GetProjectsQuery.Data.Projects.PageInfo) -> PageInfo {
        return PageInfo(
            hasNextPage: pageInfo.hasNextPage,
            endCursor: pageInfo.endCursor
        )
    }
} 
 