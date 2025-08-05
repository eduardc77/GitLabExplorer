import Foundation

// MARK: - Project Details Service Protocol
public protocol ProjectDetailsServiceProtocol: Sendable {
    func getProjectPreview(id: String) async throws -> ProjectPreview
    func getProjectSummary(id: String) async throws -> ProjectSummary
    func getProjectFullDetails(id: String) async throws -> ProjectFullDetails
    func getProjectReadme(id: String) async throws -> String?
}

// MARK: - Project Details Service
/// Handles detailed project operations using GraphQL
/// Manages caching strategy optimized for detailed project data
public final class ProjectDetailsService: ProjectDetailsServiceProtocol {
    
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
    
    // MARK: - Detail Operations
    
    /// Get project preview - medium detail level
    public func getProjectPreview(id: String) async throws -> ProjectPreview {
        return try await fetchProjectPreviewFromGraphQL(id: id)
    }
    
    /// Get project summary - lightweight version
    public func getProjectSummary(id: String) async throws -> ProjectSummary {
        let preview = try await fetchProjectPreviewFromGraphQL(id: id)
        return preview.toSummary()
    }
    
    /// Get full project details - complete information
    public func getProjectFullDetails(id: String) async throws -> ProjectFullDetails {
        // Fetch components in parallel
        async let preview = getProjectPreview(id: id)
        async let readme = getProjectReadme(id: id)
        
        // For now, create basic full details (extend with more GraphQL queries later)
        return try await ProjectFullDetails(
            preview: preview,
            readme: readme,
            languages: [], // TODO: Add languages GraphQL query
            openIssuesCount: 0, // TODO: Add issues count GraphQL query
            openMergeRequestsCount: 0, // TODO: Add MRs count GraphQL query
            licenseInfo: nil, // TODO: Add license GraphQL query
            statistics: nil // TODO: Add statistics GraphQL query
        )
    }
    
    /// Get project README content
    public func getProjectReadme(id: String) async throws -> String? {
        // TODO: Implement README fetching with GraphQL
        // For now, return nil as this would require additional GraphQL operations
        return nil
    }
    
    /// Get project with all data - convenience method for full information
    public func getProjectWithAllData(id: String) async throws -> (preview: ProjectPreview, summary: ProjectSummary, details: ProjectFullDetails) {
        async let preview = getProjectPreview(id: id)
        async let summary = getProjectSummary(id: id)
        async let details = getProjectFullDetails(id: id)
        
        return try await (preview, summary, details)
    }
    
    // MARK: - Private GraphQL Operations
    
    /// Fetch project preview using existing GraphQL infrastructure
    /// Uses the existing GetProjectsQuery but for a single project
    private func fetchProjectPreviewFromGraphQL(id: String) async throws -> ProjectPreview {
        // For now, use the existing project service to get projects and find the one with matching ID
        // In a real implementation, you'd create specific GraphQL queries for project details
        
        let result = try await projectService.getProjects(first: 100, after: nil, sort: "stars_desc")
        guard let project = result.projects.first(where: { $0.id == id }) else {
            throw GitLabError.invalidConfiguration("Project with ID \(id) not found")
        }
        
        return project.toPreviewDetailed()
    }
}

// MARK: - Preview to Summary Conversion
extension ProjectPreview {
    /// Convert ProjectPreview to lighter ProjectSummary
    func toSummary() -> ProjectSummary {
        return ProjectSummary(
            id: id,
            name: name,
            nameWithOwner: nameWithOwner,
            description: description,
            starCount: starCount,
            forkCount: forkCount,
            language: primaryLanguage,
            owner: owner,
            updatedAt: updatedAt,
            avatarURL: avatarURL,
            webURL: webURL
        )
    }
}

// MARK: - GitLabProject to Preview Conversion
extension GitLabProject {
    /// Enhanced conversion to ProjectPreview with more details
    public func toPreviewDetailed() -> ProjectPreview {
        return ProjectPreview(
            id: id,
            name: name,
            nameWithOwner: fullPath,
            description: description,
            starCount: starCount,
            forkCount: forksCount,
            primaryLanguage: nil, // Would need additional GraphQL data
            owner: ProjectOwner(
                login: namespace?.path ?? "",
                name: namespace?.name,
                avatarURL: avatarUrl,
                type: .group,
                webURL: webUrl
            ),
            updatedAt: updatedAt,
            createdAt: createdAt,
            avatarURL: avatarUrl,
            webURL: webUrl,
            visibility: visibility,
            topics: [], // Would need additional GraphQL data
            lastActivityAt: lastActivityAt
        )
    }
}
