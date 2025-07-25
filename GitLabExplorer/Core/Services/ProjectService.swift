//
//  ProjectService.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import GitLabNetwork

// MARK: - Project Models

struct Project: Codable, Identifiable {
    let id: Int
    let name: String
    let nameWithNamespace: String
    let path: String
    let pathWithNamespace: String
    let description: String?
    let defaultBranch: String?
    let visibility: ProjectVisibility
    let webUrl: String
    let httpUrlToRepo: String
    let sshUrlToRepo: String
    let avatarUrl: String?
    let starCount: Int
    let forksCount: Int
    let lastActivityAt: Date
    let createdAt: Date
    let updatedAt: Date
    let archived: Bool
    let issuesEnabled: Bool
    let mergeRequestsEnabled: Bool
    let wikiEnabled: Bool
    let jobsEnabled: Bool
    let snippetsEnabled: Bool
    let containerRegistryEnabled: Bool
    let openIssuesCount: Int
    let topics: [String]
    let namespace: ProjectNamespace
    let owner: ProjectOwner?
    let permissions: ProjectPermissions?
    let statistics: ProjectStatistics?
    
    enum CodingKeys: String, CodingKey {
        case id, name, path, description, visibility, archived, topics, namespace, owner, permissions, statistics
        case nameWithNamespace = "name_with_namespace"
        case pathWithNamespace = "path_with_namespace"
        case defaultBranch = "default_branch"
        case webUrl = "web_url"
        case httpUrlToRepo = "http_url_to_repo"
        case sshUrlToRepo = "ssh_url_to_repo"
        case avatarUrl = "avatar_url"
        case starCount = "star_count"
        case forksCount = "forks_count"
        case lastActivityAt = "last_activity_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case issuesEnabled = "issues_enabled"
        case mergeRequestsEnabled = "merge_requests_enabled"
        case wikiEnabled = "wiki_enabled"
        case jobsEnabled = "jobs_enabled"
        case snippetsEnabled = "snippets_enabled"
        case containerRegistryEnabled = "container_registry_enabled"
        case openIssuesCount = "open_issues_count"
    }
}

enum ProjectVisibility: String, Codable, CaseIterable {
    case `private` = "private"
    case `internal` = "internal"
    case `public` = "public"
    
    var displayName: String {
        switch self {
        case .private: return "Private"
        case .internal: return "Internal"
        case .public: return "Public"
        }
    }
    
    var iconName: String {
        switch self {
        case .private: return "lock.fill"
        case .internal: return "building.2.fill"
        case .public: return "globe"
        }
    }
}

struct ProjectNamespace: Codable {
    let id: Int
    let name: String
    let path: String
    let kind: String
    let fullPath: String
    let avatarUrl: String?
    let webUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, path, kind
        case fullPath = "full_path"
        case avatarUrl = "avatar_url"
        case webUrl = "web_url"
    }
}

struct ProjectOwner: Codable {
    let id: Int
    let name: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }
}

struct ProjectPermissions: Codable {
    let projectAccess: AccessLevel?
    let groupAccess: AccessLevel?
    
    enum CodingKeys: String, CodingKey {
        case projectAccess = "project_access"
        case groupAccess = "group_access"
    }
}

struct AccessLevel: Codable {
    let accessLevel: Int
    let notificationLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case accessLevel = "access_level"
        case notificationLevel = "notification_level"
    }
}

struct ProjectStatistics: Codable {
    let commitCount: Int
    let storageSize: Int
    let repositorySize: Int
    let wikiSize: Int
    let lfsObjectsSize: Int
    let jobArtifactsSize: Int
    let packagesSize: Int
    let snippetsSize: Int
    let uploadsSize: Int
    let containerRegistrySize: Int
    
    enum CodingKeys: String, CodingKey {
        case commitCount = "commit_count"
        case storageSize = "storage_size"
        case repositorySize = "repository_size"
        case wikiSize = "wiki_size"
        case lfsObjectsSize = "lfs_objects_size"
        case jobArtifactsSize = "job_artifacts_size"
        case packagesSize = "packages_size"
        case snippetsSize = "snippets_size"
        case uploadsSize = "uploads_size"
        case containerRegistrySize = "container_registry_size"
    }
}

// MARK: - Project List Parameters

struct ProjectListParameters {
    var archived: Bool?
    var visibility: ProjectVisibility?
    var orderBy: ProjectOrderBy = .lastActivityAt
    var sort: SortOrder = .desc
    var search: String?
    var simple: Bool = false
    var statistics: Bool = false
    var membership: Bool?
    var owned: Bool?
    var starred: Bool?
    var withIssuesEnabled: Bool?
    var withMergeRequestsEnabled: Bool?
    var withProgrammingLanguage: String?
    var topic: String?
    var minAccessLevel: Int?
    var lastActivityAfter: Date?
    var lastActivityBefore: Date?
    var perPage: Int = 20
    
    enum ProjectOrderBy: String, CaseIterable {
        case id = "id"
        case name = "name"
        case path = "path"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActivityAt = "last_activity_at"
        case starCount = "star_count"
        
        var displayName: String {
            switch self {
            case .id: return "ID"
            case .name: return "Name"
            case .path: return "Path"
            case .createdAt: return "Created"
            case .updatedAt: return "Updated"
            case .lastActivityAt: return "Last Activity"
            case .starCount: return "Stars"
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case asc = "asc"
        case desc = "desc"
        
        var displayName: String {
            switch self {
            case .asc: return "Ascending"
            case .desc: return "Descending"
            }
        }
    }
}

// MARK: - Pagination Response

struct PaginationInfo {
    let currentPage: Int
    let totalPages: Int?
    let totalItems: Int?
    let nextPage: Int?
    let previousPage: Int?
    let perPage: Int
    let hasMore: Bool
    
    init(headers: [String: String], currentPage: Int = 1, perPage: Int = 20) {
        self.currentPage = currentPage
        self.perPage = perPage
        
        // Parse GitLab pagination headers
        self.totalPages = headers["x-total-pages"].flatMap(Int.init)
        self.totalItems = headers["x-total"].flatMap(Int.init)
        self.nextPage = headers["x-next-page"].flatMap(Int.init)
        self.previousPage = headers["x-prev-page"].flatMap(Int.init)
        
        // Determine if there are more pages
        if let nextPage = self.nextPage {
            self.hasMore = nextPage > currentPage
        } else if let totalPages = self.totalPages {
            self.hasMore = currentPage < totalPages
        } else {
            self.hasMore = false
        }
    }
}

struct PaginatedResponse<T> {
    let items: [T]
    let pagination: PaginationInfo
}

// MARK: - Project Service

@MainActor
class ProjectService: ObservableObject {
    private let graphQLClient: GraphQLClient
    private let authService: AuthenticationService
    private let configuration: GitLabConfiguration
    
    // Service state
    @Published var isLoading = false
    @Published var error: Error?
    
    init(graphQLClient: GraphQLClient, authService: AuthenticationService) {
        self.graphQLClient = graphQLClient
        self.authService = authService
        self.configuration = authService.configuration
    }
    
    // MARK: - Public API
    
    /// Fetch projects with pagination support
    func fetchProjects(
        parameters: ProjectListParameters = ProjectListParameters(),
        page: Int = 1
    ) async throws -> PaginatedResponse<Project> {
        guard authService.isAuthenticated else {
            throw ProjectServiceError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let response = try await performProjectsRequest(parameters: parameters, page: page)
            return response
        } catch {
            self.error = error
            throw error
        }
    }
    
    /// Fetch a single project by ID
    func fetchProject(id: Int, includeStatistics: Bool = true) async throws -> Project {
        guard authService.isAuthenticated else {
            throw ProjectServiceError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let project = try await performSingleProjectRequest(id: id, includeStatistics: includeStatistics)
            return project
        } catch {
            self.error = error
            throw error
        }
    }
    
    /// Search projects by name
    func searchProjects(
        query: String,
        parameters: ProjectListParameters = ProjectListParameters(),
        page: Int = 1
    ) async throws -> PaginatedResponse<Project> {
        var searchParameters = parameters
        searchParameters.search = query
        
        return try await fetchProjects(parameters: searchParameters, page: page)
    }
    
    /// Fetch user's owned projects
    func fetchOwnedProjects(
        parameters: ProjectListParameters = ProjectListParameters(),
        page: Int = 1
    ) async throws -> PaginatedResponse<Project> {
        var ownedParameters = parameters
        ownedParameters.owned = true
        
        return try await fetchProjects(parameters: ownedParameters, page: page)
    }
    
    /// Fetch starred projects
    func fetchStarredProjects(
        parameters: ProjectListParameters = ProjectListParameters(),
        page: Int = 1
    ) async throws -> PaginatedResponse<Project> {
        var starredParameters = parameters
        starredParameters.starred = true
        
        return try await fetchProjects(parameters: starredParameters, page: page)
    }
    
    // MARK: - Private Implementation
    
    private func performProjectsRequest(
        parameters: ProjectListParameters,
        page: Int
    ) async throws -> PaginatedResponse<Project> {
        let url = try buildProjectsURL(parameters: parameters, page: page)
        
        // Create request with authentication headers
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication header if available
        if let token = try? await graphQLClient.authProvider.getValidToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProjectServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ProjectServiceError.httpError(httpResponse.statusCode)
        }
        
        // Parse projects
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let projects = try decoder.decode([Project].self, from: data)
        
        // Parse pagination info from headers
        let headers = httpResponse.allHeaderFields.compactMapValues { $0 as? String }
        let pagination = PaginationInfo(
            headers: headers,
            currentPage: page,
            perPage: parameters.perPage
        )
        
        return PaginatedResponse(items: projects, pagination: pagination)
    }
    
    private func performSingleProjectRequest(
        id: Int,
        includeStatistics: Bool
    ) async throws -> Project {
        let url = try buildSingleProjectURL(id: id, includeStatistics: includeStatistics)
        
        // Create request with authentication headers
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication header if available
        if let token = try? await graphQLClient.authProvider.getValidToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProjectServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ProjectServiceError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Project.self, from: data)
    }
    
    private func buildProjectsURL(
        parameters: ProjectListParameters,
        page: Int
    ) throws -> URL {
        guard let baseURL = URL(string: "\(configuration.baseURL)/api/v4/projects") else {
            throw ProjectServiceError.invalidURL
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        
        // Pagination
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "per_page", value: String(parameters.perPage)))
        
        // Sorting and ordering
        queryItems.append(URLQueryItem(name: "order_by", value: parameters.orderBy.rawValue))
        queryItems.append(URLQueryItem(name: "sort", value: parameters.sort.rawValue))
        
        // Filters
        if let archived = parameters.archived {
            queryItems.append(URLQueryItem(name: "archived", value: String(archived)))
        }
        
        if let visibility = parameters.visibility {
            queryItems.append(URLQueryItem(name: "visibility", value: visibility.rawValue))
        }
        
        if let search = parameters.search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        if parameters.simple {
            queryItems.append(URLQueryItem(name: "simple", value: "true"))
        }
        
        if parameters.statistics {
            queryItems.append(URLQueryItem(name: "statistics", value: "true"))
        }
        
        if let membership = parameters.membership {
            queryItems.append(URLQueryItem(name: "membership", value: String(membership)))
        }
        
        if let owned = parameters.owned {
            queryItems.append(URLQueryItem(name: "owned", value: String(owned)))
        }
        
        if let starred = parameters.starred {
            queryItems.append(URLQueryItem(name: "starred", value: String(starred)))
        }
        
        if let withIssuesEnabled = parameters.withIssuesEnabled {
            queryItems.append(URLQueryItem(name: "with_issues_enabled", value: String(withIssuesEnabled)))
        }
        
        if let withMergeRequestsEnabled = parameters.withMergeRequestsEnabled {
            queryItems.append(URLQueryItem(name: "with_merge_requests_enabled", value: String(withMergeRequestsEnabled)))
        }
        
        if let withProgrammingLanguage = parameters.withProgrammingLanguage, !withProgrammingLanguage.isEmpty {
            queryItems.append(URLQueryItem(name: "with_programming_language", value: withProgrammingLanguage))
        }
        
        if let topic = parameters.topic, !topic.isEmpty {
            queryItems.append(URLQueryItem(name: "topic", value: topic))
        }
        
        if let minAccessLevel = parameters.minAccessLevel {
            queryItems.append(URLQueryItem(name: "min_access_level", value: String(minAccessLevel)))
        }
        
        if let lastActivityAfter = parameters.lastActivityAfter {
            let formatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "last_activity_after", value: formatter.string(from: lastActivityAfter)))
        }
        
        if let lastActivityBefore = parameters.lastActivityBefore {
            let formatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "last_activity_before", value: formatter.string(from: lastActivityBefore)))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw ProjectServiceError.invalidURL
        }
        
        return url
    }
    
    private func buildSingleProjectURL(id: Int, includeStatistics: Bool) throws -> URL {
        guard let baseURL = URL(string: "\(configuration.baseURL)/api/v4/projects/\(id)") else {
            throw ProjectServiceError.invalidURL
        }
        
        if includeStatistics {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "statistics", value: "true")]
            
            guard let url = components.url else {
                throw ProjectServiceError.invalidURL
            }
            
            return url
        }
        
        return baseURL
    }
}

// MARK: - Error Types

enum ProjectServiceError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be authenticated to access projects"
        case .invalidURL:
            return "Invalid URL for projects request"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode projects: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}