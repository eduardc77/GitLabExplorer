import Foundation

// MARK: - User Projects Service Protocol
public protocol UserProjectsServiceProtocol: Sendable {
    func getUserProjects(username: String) async throws -> [ProjectSummary]
    func getUserStarredProjects(username: String) async throws -> [ProjectSummary]
    func getUserContributedProjects(username: String) async throws -> [ProjectSummary]
    func getCurrentUserProjects() async throws -> [ProjectSummary]
}

// MARK: - User Projects Service
/// Handles user-related project operations using GraphQL
/// Manages caching strategy optimized for user project data
public final class UserProjectsService: UserProjectsServiceProtocol {
    
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
    
    // MARK: - User Project Operations
    
    /// Get projects owned by a specific user
    public func getUserProjects(username: String) async throws -> [ProjectSummary] {
        return try await fetchUserProjectsFromGraphQL(username: username)
    }
    
    /// Get projects starred by a specific user
    public func getUserStarredProjects(username: String) async throws -> [ProjectSummary] {
        return try await fetchUserStarredProjectsFromGraphQL(username: username)
    }
    
    /// Get projects the user has contributed to
    public func getUserContributedProjects(username: String) async throws -> [ProjectSummary] {
        return try await fetchUserContributedProjectsFromGraphQL(username: username)
    }
    
    /// Get projects owned by the currently authenticated user
    public func getCurrentUserProjects() async throws -> [ProjectSummary] {
        return try await fetchCurrentUserProjectsFromGraphQL()
    }
    
    /// Get comprehensive user project data
    public func getUserProjectData(username: String) async throws -> UserProjectData {
        async let owned = getUserProjects(username: username)
        async let starred = getUserStarredProjects(username: username)
        async let contributed = getUserContributedProjects(username: username)
        
        return try await UserProjectData(
            owned: owned,
            starred: starred,
            contributed: contributed
        )
    }
    
    // MARK: - Private GraphQL Operations
    
    /// Fetch user's owned projects using GraphQL
    private func fetchUserProjectsFromGraphQL(username: String) async throws -> [ProjectSummary] {
        // For now, use the existing project service to get projects
        // In a real implementation, you'd create specific GraphQL queries for user projects
        let result = try await projectService.getProjects(first: 20, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
    
    /// Fetch user's starred projects using GraphQL
    private func fetchUserStarredProjectsFromGraphQL(username: String) async throws -> [ProjectSummary] {
        // For now, use the existing project service to get projects
        // In a real implementation, you'd create specific GraphQL queries for user starred projects
        let result = try await projectService.getProjects(first: 20, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
    
    /// Fetch user's contributed projects using GraphQL
    private func fetchUserContributedProjectsFromGraphQL(username: String) async throws -> [ProjectSummary] {
        // For now, use the existing project service to get projects
        // In a real implementation, you'd create specific GraphQL queries for user contributed projects
        let result = try await projectService.getProjects(first: 20, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
    
    /// Fetch current user's projects using GraphQL
    private func fetchCurrentUserProjectsFromGraphQL() async throws -> [ProjectSummary] {
        // For now, use the existing project service to get projects
        // In a real implementation, you'd create specific GraphQL queries for current user projects
        let result = try await projectService.getProjects(first: 20, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
}

// MARK: - User Project Data Container
public struct UserProjectData: Sendable {
    public let owned: [ProjectSummary]
    public let starred: [ProjectSummary]
    public let contributed: [ProjectSummary]
    
    public init(
        owned: [ProjectSummary],
        starred: [ProjectSummary],
        contributed: [ProjectSummary]
    ) {
        self.owned = owned
        self.starred = starred
        self.contributed = contributed
    }
    
    /// Total number of projects across all categories
    public var totalProjectCount: Int {
        owned.count + starred.count + contributed.count
    }
    
    /// Get all unique projects (removing duplicates across categories)
    public var allUniqueProjects: [ProjectSummary] {
        var seen = Set<String>()
        var unique: [ProjectSummary] = []
        
        for project in owned + starred + contributed {
            if !seen.contains(project.id) {
                seen.insert(project.id)
                unique.append(project)
            }
        }
        
        return unique
    }
}

// MARK: - User Project Extensions
extension UserProjectsService {
    
    /// Check if user has any projects
    public func hasProjects(username: String) async throws -> Bool {
        let projects = try await getUserProjects(username: username)
        return !projects.isEmpty
    }
    
    /// Get user's most starred project
    public func getUserMostStarredProject(username: String) async throws -> ProjectSummary? {
        let projects = try await getUserProjects(username: username)
        return projects.max { $0.starCount < $1.starCount }
    }
    
    /// Get user's most recent project
    public func getUserMostRecentProject(username: String) async throws -> ProjectSummary? {
        let projects = try await getUserProjects(username: username)
        return projects.max { $0.updatedAt < $1.updatedAt }
    }
}
