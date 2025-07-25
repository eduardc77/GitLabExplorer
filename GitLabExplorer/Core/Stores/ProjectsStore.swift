//
//  ProjectsStore.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import SwiftUI
import GitLabNetwork

/// Store for managing projects state with infinite scroll support
@MainActor
@Observable
final class ProjectsStore {
    
    // MARK: - Published State
    
    /// Current projects
    public private(set) var projects: [GitLabProject] = []
    
    /// Loading state
    public private(set) var isLoading = false
    
    /// Loading more (for infinite scroll)
    public private(set) var isLoadingMore = false
    
    /// Error state
    public private(set) var error: GitLabError?
    
    /// Pagination info
    public private(set) var hasNextPage = false
    public private(set) var endCursor: String?
    
    // MARK: - Dependencies
    
    private let projectService: ProjectService
    
    // MARK: - Initialization
    
    init(projectService: ProjectService) {
        self.projectService = projectService
    }
    
    // MARK: - Public Actions
    
    /// Initial load of projects
    func loadProjects() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await projectService.getProjects(first: 20, after: nil)
            
            projects = result.projects
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    /// Load more projects (infinite scroll)
    func loadMoreProjects() async {
        guard hasNextPage && !isLoadingMore && !isLoading else { return }
        
        isLoadingMore = true
        
        do {
            let result = try await projectService.getProjects(first: 20, after: endCursor)
            
            // Append new projects to existing ones
            projects.append(contentsOf: result.projects)
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoadingMore = false
    }
    
    /// Refresh projects (pull to refresh)
    func refresh() async {
        projects = []
        endCursor = nil
        hasNextPage = false
        await loadProjects()
    }
    
    /// Clear error state
    func clearError() {
        error = nil
    }
    
    // MARK: - Preview Helper
    
    /// Convenience initializer for SwiftUI previews
    convenience init() {
        let configuration = GitLabConfiguration.preview()
        
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        let projectService = ProjectService(graphQLClient: graphQLClient, authService: authService)
        
        self.init(projectService: projectService)
    }
}

// MARK: - Computed Properties

extension ProjectsStore {
    /// Whether there are any projects
    var hasProjects: Bool {
        !projects.isEmpty
    }
    
    /// Whether we're in an empty state (not loading and no projects)
    var isEmpty: Bool {
        !isLoading && projects.isEmpty
    }
} 
