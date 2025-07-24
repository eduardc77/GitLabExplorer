//
//  GitLabExplorerApp.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

@main
struct GitLabExplorerApp: App {
    @State private var authStore = AuthenticationStore()
    @State private var notificationsStore: NotificationsStore
    
    init() {
        let authStore = AuthenticationStore()
        
        // Create shared dependencies (should be singletons in real app)
        let configuration = GitLabConfiguration(
            baseURL: URL(string: "https://gitlab.com")!,
            clientID: "4e130d01a21e737b17beb754b61d3018831b5c564069e649375761dd9d772b7e",
            redirectURI: "gitlabexplorer://auth/callback"
        )
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        
        // Create independent services
        let notificationService = NotificationService(graphQLClient: graphQLClient, authService: authService)
        
        // Create independent stores
        let notificationsStore = NotificationsStore(
            notificationService: notificationService,
            authStore: authStore
        )
        
        self._authStore = State(initialValue: authStore)
        self._notificationsStore = State(initialValue: notificationsStore)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
                .environment(notificationsStore)
                .task {
                    // Check authentication state on app launch
                    await authStore.refreshAuthState()
                }
        }
    }
}
