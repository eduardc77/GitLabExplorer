/// Service for project-related GitLab operations
/// This is a pure business logic service - UI state belongs in ViewModels
public final class ProjectService: Sendable {
    
    // MARK: - Properties
    
    private let graphQLClient: GraphQLClient
    private let authManager: AuthenticationManager?
    
    // MARK: - Initialization
    
    /// Initialize with existing dependencies
    public init(graphQLClient: GraphQLClient, authManager: AuthenticationManager? = nil) {
        self.graphQLClient = graphQLClient
        self.authManager = authManager
    }
    
    /// Convenience initializer - creates its own dependencies
    public convenience init(configuration: GitLabConfiguration, authManager: AuthenticationManager? = nil) {
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let apolloClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        self.init(graphQLClient: apolloClient, authManager: authManager)
    }
    
    // MARK: - Project Operations
    
    /// Get user's projects
    public func getUserProjects(userId: String) async throws -> [GitLabProject] {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create UserProjects.graphql query
        throw GitLabError.invalidConfiguration("UserProjects query not created yet. Add UserProjects.graphql operation.")
    }
    
    /// Search projects
    public func searchProjects(query: String, limit: Int = 20) async throws -> [GitLabProject] {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create SearchProjects.graphql query
        throw GitLabError.invalidConfiguration("SearchProjects query not implemented yet")
    }
    
    /// Get project by ID
    public func getProject(id: String) async throws -> GitLabProject? {
        // Check authentication if auth manager is available
        if let authManager = authManager {
            guard await authManager.isAuthenticated else {
                throw GitLabError.authenticationRequired
            }
        }
        
        // TODO: Create GetProject.graphql query
        throw GitLabError.invalidConfiguration("GetProject query not implemented yet")
    }
} 
