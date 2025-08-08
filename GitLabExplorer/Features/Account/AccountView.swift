//
//  AccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ServiceFactory.self) private var serviceFactory
    @Environment(AccountCoordinator.self) private var accountCoordinator
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack(path: Bindable(accountCoordinator).navigationPath) {
            Group {
                if authStore.isAuthenticated {
                    AuthenticatedAccountView()
                } else {
                    UnauthenticatedAccountView()
                }
            }
            .navigationTitle("Account")
            .navigationDestination(for: AccountCoordinator.Destination.self) { destination in
                switch destination {
                case .personalProjects:
                    PersonalProjectsView(serviceFactory: serviceFactory)
                case .groups:
                    Text("Groups - Coming Soon")
                        .navigationTitle("Groups")
                case .assignedIssues:
                    Text("Assigned Issues - Coming Soon")
                        .navigationTitle("Assigned Issues")
                case .mergeRequests:
                    Text("Merge Requests - Coming Soon")
                        .navigationTitle("Merge Requests")
                }
            }
            .toolbar {
                if authStore.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                AccountSettingsView()
            }
            .alert("Authentication Error", isPresented: .constant(authStore.authError != nil)) {
                Button("OK") {
                    authStore.clearError()
                }
            } message: {
                if let error = authStore.authError {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthenticationStore())
}
 
