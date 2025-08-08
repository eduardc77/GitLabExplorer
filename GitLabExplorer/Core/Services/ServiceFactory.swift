//
//  ServiceFactory.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import GitLabNetwork

/// Central factory for creating and managing all services
@MainActor
@Observable
final class ServiceFactory {
    
    // MARK: - Shared Dependencies
    
    private let configuration: GitLabConfiguration
    private let authProvider: GitLabAuthProvider
    private let graphQLClient: GraphQLClient
    let authService: AuthenticationService // Exposed for app initialization
    
    // MARK: - Services
    
    private(set) var exploreProjectsService: ExploreProjectsService
    private(set) var searchService: ProjectSearchService
    private(set) var notificationService: NotificationService
    private(set) var personalProjectsService: PersonalProjectsService
    
    // MARK: - Initialization
    
    init(configuration: GitLabConfiguration, authProvider: GitLabAuthProvider) {
        self.configuration = configuration
        self.authProvider = authProvider
        
        // Create shared dependencies
        self.graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        self.authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        
        // Initialize services
        self.exploreProjectsService = ExploreProjectsService(configuration: configuration, authProvider: authProvider)
        self.searchService = ProjectSearchService(configuration: configuration, authProvider: authProvider)
        self.notificationService = NotificationService(graphQLClient: graphQLClient, authService: authService)
        self.personalProjectsService = PersonalProjectsService(configuration: configuration, authProvider: authProvider)
    }
    
    // MARK: - Store Creation
    
    /// Create a ProjectsStore with all required services
    func createProjectsStore() -> ProjectsStore {
        ProjectsStore(
            exploreProjectsService: exploreProjectsService,
            searchService: searchService
        )
    }
    
    /// Create a NotificationsStore with all required services
    func createNotificationsStore(authStore: AuthenticationStore) -> NotificationsStore {
        NotificationsStore(notificationService: notificationService, authStore: authStore)
    }
    
    /// Create a PersonalProjectsStore with all required services
    func createPersonalProjectsStore() -> PersonalProjectsStore {
        PersonalProjectsStore(personalProjectsService: personalProjectsService)
    }
} 
