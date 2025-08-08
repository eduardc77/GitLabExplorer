//
//  HomeView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct HomeView: View {
    @Environment(HomeCoordinator.self) private var coordinator
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ServiceFactory.self) private var serviceFactory
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            List {
                Section {
                    HomeFeatureRow(
                        icon: "folder.fill",
                        title: "Projects",
                        subtitle: "Explore repositories and codebases",
                        iconColor: .blue,
                        destination: .projects
                    )
                    
                    HomeFeatureRow(
                        icon: "person.2.fill",
                        title: "Users",
                        subtitle: "Discover developers and contributors",
                        iconColor: .green,
                        destination: .users
                    )

                    HomeFeatureRow(
                        icon: "person.3.fill",
                        title: "Groups",
                        subtitle: "Browse organizations and teams",
                        iconColor: .orange,
                        destination: .groups
                    )

                    HomeFeatureRow(
                        icon: "tag.fill",
                        title: "Topics",
                        subtitle: "Explore projects by technology and interests",
                        iconColor: .purple,
                        destination: .topics
                    )
                } header: {
                    Text("Explore GitLab")
                }
            }
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search projects, users, groups...")
            .navigationDestination(for: HomeCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ProjectsView(serviceFactory: serviceFactory)
                case .users:
                    UsersView()
                case .groups:
                    Text("Groups - Coming Soon")
                        .navigationTitle("Groups")
                case .topics:
                    Text("Topics - Coming Soon")
                        .navigationTitle("Topics")
                case .projectDetail(_):
                    Text("Product Details - Coming Soon")
                case .userDetail(_):
                    Text("User Details - Coming Soon")
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct HomeFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let destination: HomeCoordinator.Destination
    
    var body: some View {
        NavigationLink(value: destination) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .environment(HomeCoordinator())
        .environment(AuthenticationStore())
        .environment(ServiceFactory(configuration: GitLabConfiguration.fromInfoPlist(), authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))))
} 
