import Foundation

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
    
    /// Get user's projects
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
 