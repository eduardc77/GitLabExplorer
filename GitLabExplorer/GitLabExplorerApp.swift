//
//  GitLabExplorerApp.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

@main
struct GitLabExplorerApp: App {
    @State private var authStore = AuthenticationStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
                .task {
                    // Check authentication state on app launch
                    await authStore.refreshAuthState()
                }
        }
    }
}
