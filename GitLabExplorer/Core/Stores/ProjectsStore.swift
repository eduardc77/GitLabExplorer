//
//  ProjectsStore.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class ProjectsStore {
    // MARK: - Dependencies
    private let projectService: ProjectService
    private let authStore: AuthenticationStore
    
    // MARK: - State
    private(set) var projects: [Project] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var error: Error?
    private(set) var currentPage = 1
    private(set) var hasMorePages = true
    private(set) var totalProjects: Int?
    
    // MARK: - Search and Filter State
    var searchText = ""
    var selectedVisibility: ProjectVisibility?
    var showArchivedProjects = false
    var sortOrder: ProjectListParameters.ProjectOrderBy = .lastActivityAt
    var sortDirection: ProjectListParameters.SortOrder = .desc
    var selectedFilter: ProjectFilter = .all
    
    // MARK: - Filter Options
    enum ProjectFilter: String, CaseIterable {
        case all = "all"
        case owned = "owned"
        case starred = "starred"
        case membership = "membership"
        
        var displayName: String {
            switch self {
            case .all: return "All Projects"
            case .owned: return "Owned"
            case .starred: return "Starred"
            case .membership: return "Member"
            }
        }
        
        var iconName: String {
            switch self {
            case .all: return "folder.fill"
            case .owned: return "person.fill"
            case .starred: return "star.fill"
            case .membership: return "person.2.fill"
            }
        }
    }
    
    // MARK: - Computed Properties
    var filteredProjects: [Project] {
        var filtered = projects
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.nameWithNamespace.localizedCaseInsensitiveContains(searchText) ||
                project.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return filtered
    }
    
    var isEmpty: Bool {
        projects.isEmpty && !isLoading
    }
    
    var showEmptyState: Bool {
        isEmpty && error == nil
    }
    
    var showErrorState: Bool {
        error != nil && projects.isEmpty
    }
    
    // MARK: - Initialization
    init(projectService: ProjectService, authStore: AuthenticationStore) {
        self.projectService = projectService
        self.authStore = authStore
    }
    
    // MARK: - Public Methods
    
    /// Load projects with current filters
    func loadProjects() async {
        guard authStore.isAuthenticated else { return }
        
        isLoading = true
        error = nil
        currentPage = 1
        hasMorePages = true
        
        defer {
            isLoading = false
        }
        
        do {
            let parameters = buildParameters()
            let response = try await projectService.fetchProjects(parameters: parameters, page: 1)
            
            projects = response.items
            currentPage = response.pagination.currentPage
            hasMorePages = response.pagination.hasMore
            totalProjects = response.pagination.totalItems
            
        } catch {
            self.error = error
            projects = []
        }
    }
    
    /// Load more projects (pagination)
    func loadMoreProjects() async {
        guard !isLoadingMore && hasMorePages && authStore.isAuthenticated else { return }
        
        isLoadingMore = true
        
        defer {
            isLoadingMore = false
        }
        
        do {
            let parameters = buildParameters()
            let nextPage = currentPage + 1
            let response = try await projectService.fetchProjects(parameters: parameters, page: nextPage)
            
            projects.append(contentsOf: response.items)
            currentPage = response.pagination.currentPage
            hasMorePages = response.pagination.hasMore
            totalProjects = response.pagination.totalItems
            
        } catch {
            // Don't replace the main error if we already have projects
            if projects.isEmpty {
                self.error = error
            }
        }
    }
    
    /// Refresh projects (pull-to-refresh)
    func refreshProjects() async {
        await loadProjects()
    }
    
    /// Search projects with debouncing
    func searchProjects(query: String) async {
        searchText = query
        
        // Debounce search to avoid too many API calls
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        // Check if search text is still the same after debounce
        guard searchText == query else { return }
        
        await loadProjects()
    }
    
    /// Update filter and reload
    func updateFilter(_ filter: ProjectFilter) async {
        selectedFilter = filter
        await loadProjects()
    }
    
    /// Update visibility filter and reload
    func updateVisibility(_ visibility: ProjectVisibility?) async {
        selectedVisibility = visibility
        await loadProjects()
    }
    
    /// Update sort order and reload
    func updateSortOrder(_ orderBy: ProjectListParameters.ProjectOrderBy, direction: ProjectListParameters.SortOrder) async {
        sortOrder = orderBy
        sortDirection = direction
        await loadProjects()
    }
    
    /// Toggle archived projects filter
    func toggleArchivedProjects() async {
        showArchivedProjects.toggle()
        await loadProjects()
    }
    
    /// Clear error state
    func clearError() {
        error = nil
    }
    
    /// Get project by ID
    func project(withId id: Int) -> Project? {
        projects.first { $0.id == id }
    }
    
    /// Check if should load more when reaching end of list
    func shouldLoadMore(for project: Project) -> Bool {
        guard let lastProject = projects.last else { return false }
        return project.id == lastProject.id && hasMorePages && !isLoadingMore
    }
    
    // MARK: - Private Methods
    
    private func buildParameters() -> ProjectListParameters {
        var parameters = ProjectListParameters()
        
        // Apply current filters
        parameters.orderBy = sortOrder
        parameters.sort = sortDirection
        parameters.visibility = selectedVisibility
        parameters.statistics = true
        parameters.perPage = 20
        
        // Apply archived filter
        if !showArchivedProjects {
            parameters.archived = false
        }
        
        // Apply project filter
        switch selectedFilter {
        case .all:
            break // No additional filter
        case .owned:
            parameters.owned = true
        case .starred:
            parameters.starred = true
        case .membership:
            parameters.membership = true
        }
        
        // Apply search
        if !searchText.isEmpty {
            parameters.search = searchText
        }
        
        return parameters
    }
}

// MARK: - Extensions

extension ProjectsStore {
    /// Convenience method to check if a project is owned by current user
    func isProjectOwned(_ project: Project) -> Bool {
        // This would need to be implemented based on your auth system
        // For now, we'll use the owned flag from the API response
        return selectedFilter == .owned
    }
    
    /// Convenience method to get project visibility icon
    func visibilityIcon(for project: Project) -> String {
        project.visibility.iconName
    }
    
    /// Convenience method to format project statistics
    func formattedStatistics(for project: Project) -> String? {
        guard let stats = project.statistics else { return nil }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(stats.repositorySize))
    }
    
    /// Convenience method to format last activity
    func formattedLastActivity(for project: Project) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: project.lastActivityAt, relativeTo: Date())
    }
}

// MARK: - Mock Data for Previews

#if DEBUG
extension ProjectsStore {
    static func mock() -> ProjectsStore {
        let mockAuthStore = AuthenticationStore()
        let mockProjectService = ProjectService(
            graphQLClient: GraphQLClient(
                configuration: GitLabConfiguration.fromInfoPlist(),
                authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))
            ),
            authService: AuthenticationService(
                configuration: GitLabConfiguration.fromInfoPlist(),
                graphQLClient: GraphQLClient(
                    configuration: GitLabConfiguration.fromInfoPlist(),
                    authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))
                )
            )
        )
        
        return ProjectsStore(projectService: mockProjectService, authStore: mockAuthStore)
    }
    
    func loadMockData() {
        projects = [
            Project(
                id: 1,
                name: "GitLabExplorer",
                nameWithNamespace: "user / GitLabExplorer",
                path: "gitlabexplorer",
                pathWithNamespace: "user/gitlabexplorer",
                description: "A beautiful GitLab client for iOS",
                defaultBranch: "main",
                visibility: .public,
                webUrl: "https://gitlab.com/user/gitlabexplorer",
                httpUrlToRepo: "https://gitlab.com/user/gitlabexplorer.git",
                sshUrlToRepo: "git@gitlab.com:user/gitlabexplorer.git",
                avatarUrl: nil,
                starCount: 15,
                forksCount: 3,
                lastActivityAt: Date().addingTimeInterval(-3600),
                createdAt: Date().addingTimeInterval(-86400 * 30),
                updatedAt: Date().addingTimeInterval(-1800),
                archived: false,
                issuesEnabled: true,
                mergeRequestsEnabled: true,
                wikiEnabled: true,
                jobsEnabled: true,
                snippetsEnabled: true,
                containerRegistryEnabled: true,
                openIssuesCount: 5,
                topics: ["ios", "swift", "gitlab"],
                namespace: ProjectNamespace(
                    id: 1,
                    name: "user",
                    path: "user",
                    kind: "user",
                    fullPath: "user",
                    avatarUrl: nil,
                    webUrl: "https://gitlab.com/user"
                ),
                owner: ProjectOwner(
                    id: 1,
                    name: "User",
                    createdAt: Date().addingTimeInterval(-86400 * 365)
                ),
                permissions: nil,
                statistics: ProjectStatistics(
                    commitCount: 127,
                    storageSize: 1024000,
                    repositorySize: 512000,
                    wikiSize: 0,
                    lfsObjectsSize: 0,
                    jobArtifactsSize: 256000,
                    packagesSize: 0,
                    snippetsSize: 0,
                    uploadsSize: 256000,
                    containerRegistrySize: 0
                )
            )
        ]
    }
}
#endif