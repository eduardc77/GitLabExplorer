import Foundation

// MARK: - Supporting Types
/// Result structure for paginated search operations
public struct ProjectSearchResult: Sendable, Codable {
    public let results: [ProjectSummary]
    public let hasNextPage: Bool
    
    public init(results: [ProjectSummary], hasNextPage: Bool) {
        self.results = results
        self.hasNextPage = hasNextPage
    }
}

// MARK: - Project Search Service Protocol
public protocol ProjectSearchServiceProtocol: Sendable {
    func searchProjects(query: String, sort: ProjectSort) async throws -> [ProjectSummary]
    func searchProjectsByLanguage(language: String, limit: Int) async throws -> [ProjectSummary]
}

// MARK: - Project Search Service
/// Handles project search operations using GraphQL API
/// Manages caching strategy optimized for search results (short TTL)
public final class ProjectSearchService: ProjectSearchServiceProtocol {
    
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
    
    // MARK: - Search Operations
    
    /// Search projects by text query with sorting - Protocol conformance method
    public func searchProjects(query: String, sort: ProjectSort) async throws -> [ProjectSummary] {
        return try await searchProjects(query: query, sort: sort, limit: 20)
    }
    
    /// Search projects by text query with sorting
    public func searchProjects(
        query: String, 
        sort: ProjectSort = .relevance,
        limit: Int = 20
    ) async throws -> [ProjectSummary] {
        // For now, use the same GraphQL query but with search parameters
        // TODO: Create dedicated search GraphQL query when available
        let result = try await projectService.getProjects(first: limit, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
    
    /// Search projects by programming language/topic
    public func searchProjectsByLanguage(
        language: String, 
        limit: Int = 20
    ) async throws -> [ProjectSummary] {
        // For now, use the same GraphQL query but with search parameters
        // TODO: Create dedicated language search GraphQL query when available
        let result = try await projectService.getProjects(first: limit, after: nil, sort: "stars_desc")
        return result.projects.map { $0.toSummary() }
    }
    
    /// Advanced search with multiple parameters
    public func advancedSearch(
        query: String,
        language: String? = nil,
        sort: ProjectSort = .relevance,
        limit: Int = 20
    ) async throws -> [ProjectSummary] {
        
        // If language is specified, combine text search with language filter
        if let language = language {
            // For now, prioritize language search - could be enhanced to combine both
            return try await searchProjectsByLanguage(language: language, limit: limit)
        } else {
            return try await searchProjects(query: query, sort: sort, limit: limit)
        }
    }
    
    /// Search with pagination support
    public func searchProjectsPaginated(
        query: String,
        sort: ProjectSort = .relevance,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> ProjectSearchResult {
        // For now, use the same GraphQL query but with search parameters
        // TODO: Create dedicated search GraphQL query when available
        let result = try await projectService.getProjects(first: perPage, after: nil, sort: "stars_desc")
        let summaries = result.projects.map { $0.toSummary() }
        
        // Estimate if there are more pages (simple heuristic)
        let hasNextPage = summaries.count >= perPage
        return ProjectSearchResult(results: summaries, hasNextPage: hasNextPage)
    }

}

// MARK: - Search Utilities
extension ProjectSearchService {
    
    /// Get popular programming languages for search suggestions
    public func getPopularLanguages() -> [String] {
        return [
            "Swift",
            "JavaScript", 
            "TypeScript",
            "Python",
            "Go",
            "Rust",
            "Java",
            "Kotlin",
            "C++",
            "Ruby",
            "PHP",
            "C#",
            "Dart",
            "Vue",
            "React"
        ]
    }
    
    /// Validate search query
    public func isValidSearchQuery(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && trimmed.count <= 100
    }
} 
