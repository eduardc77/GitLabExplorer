import Foundation

/// Service for managing personal projects (owned, starred, contributed)
public protocol PersonalProjectsServiceProtocol: Sendable {
    /// Get current user's personal projects (owned by the user)
    func getPersonalProjects() async throws -> [ProjectSummary]
    
    /// Get current user's starred projects
    func getStarredProjects() async throws -> [ProjectSummary]
    
    /// Get current user's contributed projects
    func getContributedProjects() async throws -> [ProjectSummary]
    
    /// Get all personal projects (owned, starred, contributed) as a combined data structure
    func getAllPersonalProjects() async throws -> PersonalProjectData
}

/// Data container for personal projects
public struct PersonalProjectData: Sendable {
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

/// Implementation of PersonalProjectsService
public final class PersonalProjectsService: PersonalProjectsServiceProtocol {
    private let graphQLClient: GraphQLClient

    public init(graphQLClient: GraphQLClient) {
        self.graphQLClient = graphQLClient
    }

    public convenience init(configuration: GitLabConfiguration, authProvider: GitLabAuthProvider) {
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        self.init(graphQLClient: graphQLClient)
    }

    // MARK: - Public Methods

    public func getPersonalProjects() async throws -> [ProjectSummary] {
        return try await fetchPersonalProjectsFromGraphQL()
    }

    public func getStarredProjects() async throws -> [ProjectSummary] {
        return try await fetchStarredProjectsFromGraphQL()
    }

    public func getContributedProjects() async throws -> [ProjectSummary] {
        return try await fetchContributedProjectsFromGraphQL()
    }

    public func getAllPersonalProjects() async throws -> PersonalProjectData {
        async let owned = getPersonalProjects()
        async let starred = getStarredProjects()
        async let contributed = getContributedProjects()
        
        return try await PersonalProjectData(
            owned: owned,
            starred: starred,
            contributed: contributed
        )
    }

    // MARK: - Private GraphQL Operations

    /// Fetch user's personal projects using GraphQL
    private func fetchPersonalProjectsFromGraphQL() async throws -> [ProjectSummary] {
        let query = GitLabAPI.GetUserPersonalProjectsQuery(
            first: .some(20),
            after: .none
        )
        
        return try await graphQLClient.executeQueryAndExtractData(query) { data in
            guard let projectsConnection = data.projects else {
                throw GitLabError.invalidResponse("No personal projects data received")
            }
            
            let projects = projectsConnection.edges?.compactMap { edge -> ProjectSummary? in
                guard let node = edge?.node else { return nil }
                
                return ProjectSummary(
                    id: node.id,
                    name: node.name,
                    nameWithOwner: node.fullPath,
                    description: node.description,
                    starCount: node.starCount,
                    forkCount: node.forksCount,
                    language: nil, // GitLab doesn't provide this in the API
                    owner: ProjectOwner(
                        login: node.namespace?.path ?? "",
                        name: node.namespace?.name ?? "",
                        avatarURL: node.namespace?.avatarUrl.flatMap { URL(string: $0) },
                        type: .user,
                        webURL: node.namespace?.webUrl.flatMap { URL(string: $0) }
                    ),
                    updatedAt: node.updatedAt?.date ?? Date(),
                    avatarURL: node.avatarUrl.flatMap { URL(string: $0) },
                    webURL: node.webUrl.flatMap { URL(string: $0) } ?? URL(string: "https://gitlab.com")!
                )
            } ?? []
            
            return projects
        }
    }

    /// Fetch user's starred projects using GraphQL
    private func fetchStarredProjectsFromGraphQL() async throws -> [ProjectSummary] {
        let query = GitLabAPI.GetUserStarredProjectsQuery(
            first: .some(20),
            after: .none
        )
        
        return try await graphQLClient.executeQueryAndExtractData(query) { data in
            guard let projectsConnection = data.projects else {
                throw GitLabError.invalidResponse("No starred projects data received")
            }
            
            let projects = projectsConnection.edges?.compactMap { edge -> ProjectSummary? in
                guard let node = edge?.node else { return nil }
                
                return ProjectSummary(
                    id: node.id,
                    name: node.name,
                    nameWithOwner: node.fullPath,
                    description: node.description,
                    starCount: node.starCount,
                    forkCount: node.forksCount,
                    language: nil, // GitLab doesn't provide this in the API
                    owner: ProjectOwner(
                        login: node.namespace?.path ?? "",
                        name: node.namespace?.name ?? "",
                        avatarURL: node.namespace?.avatarUrl.flatMap { URL(string: $0) },
                        type: .user,
                        webURL: node.namespace?.webUrl.flatMap { URL(string: $0) }
                    ),
                    updatedAt: node.updatedAt?.date ?? Date(),
                    avatarURL: node.avatarUrl.flatMap { URL(string: $0) },
                    webURL: node.webUrl.flatMap { URL(string: $0) } ?? URL(string: "https://gitlab.com")!
                )
            } ?? []
            
            return projects
        }
    }

    /// Fetch user's contributed projects using GraphQL
    private func fetchContributedProjectsFromGraphQL() async throws -> [ProjectSummary] {
        let query = GitLabAPI.GetUserContributedProjectsQuery(
            first: .some(20),
            after: .none
        )
        
        return try await graphQLClient.executeQueryAndExtractData(query) { data in
            guard let projectsConnection = data.projects else {
                throw GitLabError.invalidResponse("No contributed projects data received")
            }
            
            let projects = projectsConnection.edges?.compactMap { edge -> ProjectSummary? in
                guard let node = edge?.node else { return nil }
                
                return ProjectSummary(
                    id: node.id,
                    name: node.name,
                    nameWithOwner: node.fullPath,
                    description: node.description,
                    starCount: node.starCount,
                    forkCount: node.forksCount,
                    language: nil, // GitLab doesn't provide this in the API
                    owner: ProjectOwner(
                        login: node.namespace?.path ?? "",
                        name: node.namespace?.name ?? "",
                        avatarURL: node.namespace?.avatarUrl.flatMap { URL(string: $0) },
                        type: .user,
                        webURL: node.namespace?.webUrl.flatMap { URL(string: $0) }
                    ),
                    updatedAt: node.updatedAt?.date ?? Date(),
                    avatarURL: node.avatarUrl.flatMap { URL(string: $0) },
                    webURL: node.webUrl.flatMap { URL(string: $0) } ?? URL(string: "https://gitlab.com")!
                )
            } ?? []
            
            return projects
        }
    }
}

// MARK: - Personal Project Extensions

extension PersonalProjectsService {
    
    /// Check if user has any personal projects
    public func hasPersonalProjects() async throws -> Bool {
        let projects = try await getPersonalProjects()
        return !projects.isEmpty
    }
    
    /// Get user's most starred personal project
    public func getMostStarredPersonalProject() async throws -> ProjectSummary? {
        let projects = try await getPersonalProjects()
        return projects.max { $0.starCount < $1.starCount }
    }
    
    /// Get user's most recent personal project
    public func getMostRecentPersonalProject() async throws -> ProjectSummary? {
        let projects = try await getPersonalProjects()
        return projects.max { $0.updatedAt < $1.updatedAt }
    }
} 
