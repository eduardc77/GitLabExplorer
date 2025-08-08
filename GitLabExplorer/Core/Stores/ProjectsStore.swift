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
    
    // MARK: - Configuration
    
    /// Default page size for pagination
    private let defaultPageSize = 20
    
    // MARK: - Published State
    
    /// Current projects
    public private(set) var projects: [ProjectSummary] = []
    
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
    
    private let exploreProjectsService: ExploreProjectsServiceProtocol
    private let searchService: ProjectSearchServiceProtocol
    
    // MARK: - Initialization
    
    init(exploreProjectsService: ExploreProjectsServiceProtocol, searchService: ProjectSearchServiceProtocol) {
        self.exploreProjectsService = exploreProjectsService
        self.searchService = searchService
    }

    // MARK: - Public Actions
    
    /// Initial load of projects (using discovery data)
    func loadProjects() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Load most starred projects as the main list using GraphQL with proper cursor-based pagination
            let result = try await exploreProjectsService.getMostStarredProjects(limit: defaultPageSize, after: nil)
            projects = result.projects.map { $0.toSummary() }
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
            // Load more projects using GraphQL cursor-based pagination
            let result = try await exploreProjectsService.getMostStarredProjects(limit: defaultPageSize, after: endCursor)
            
            // Append new projects to existing ones, avoiding duplicates
            let newProjects = result.projects.map { $0.toSummary() }.filter { newProject in
                !projects.contains { existingProject in
                    existingProject.id == newProject.id
                }
            }
            
            projects.append(contentsOf: newProjects)
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

    /// Reset store state (clear all projects and pagination)
    func reset() {
        projects = []
        endCursor = nil
        hasNextPage = false
        isLoading = false
        isLoadingMore = false
        error = nil
    }

    // MARK: - Discovery Actions (REST Fallback)
    
    /// Load trending projects
    func loadTrendingProjects() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await exploreProjectsService.getTrendingProjects(limit: defaultPageSize, after: nil)
            
            projects = result.projects.map { $0.toSummary() }
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    /// Load most starred projects
    func loadMostStarredProjects() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await exploreProjectsService.getMostStarredProjects(limit: defaultPageSize, after: nil)
            
            projects = result.projects.map { $0.toSummary() }
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    /// Load active projects
    func loadActiveProjects() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let result = try await exploreProjectsService.getActiveProjects(limit: defaultPageSize, after: nil)
            
            projects = result.projects.map { $0.toSummary() }
            hasNextPage = result.pageInfo.hasNextPage
            endCursor = result.pageInfo.endCursor
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Search Actions
    
    /// Search projects by query
    func searchProjects(query: String, sort: ProjectSort = .relevance) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let searchResults = try await searchService.searchProjects(query: query, sort: sort)
            
            projects = searchResults
            hasNextPage = searchResults.count >= defaultPageSize
            endCursor = "2"
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    /// Search projects by programming language
    func searchProjectsByLanguage(_ language: String) async {
        guard !isLoading else { return }
        
        isLoading = true 
        error = nil
        
        do {
            let languageResults = try await searchService.searchProjectsByLanguage(language: language, limit: defaultPageSize)
            
            projects = languageResults
            hasNextPage = languageResults.count >= defaultPageSize
            endCursor = "2"
            
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Preview Helper
    
    /// Convenience initializer for SwiftUI previews
    convenience init() {
        let configuration = GitLabConfiguration.preview()
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        
        // Create the specialized services
        let exploreProjectsService = ExploreProjectsService(configuration: configuration, authProvider: authProvider)
        let searchService = ProjectSearchService(configuration: configuration, authProvider: authProvider)
        
        self.init(exploreProjectsService: exploreProjectsService, searchService: searchService)
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
