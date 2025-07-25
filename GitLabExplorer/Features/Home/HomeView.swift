//
//  HomeView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HomeFeatureRow(
                        icon: "folder.fill",
                        title: "Projects",
                        subtitle: "Explore repositories and codebases",
                        iconColor: .blue
                    ) {
                        ProjectsView()
                    }
                    
                    HomeFeatureRow(
                        icon: "person.2.fill",
                        title: "Users",
                        subtitle: "Discover developers and contributors",
                        iconColor: .green
                    ) {
                        UsersView()
                    }
                    
                    HomeFeatureRow(
                        icon: "person.3.fill",
                        title: "Groups",
                        subtitle: "Browse organizations and teams",
                        iconColor: .orange
                    ) {
                        // TODO: Create GroupsView
                        Text("Groups - Coming Soon")
                            .navigationTitle("Groups")
                    }
                    
                    HomeFeatureRow(
                        icon: "tag.fill",
                        title: "Topics",
                        subtitle: "Explore projects by technology and interests",
                        iconColor: .purple
                    ) {
                        // TODO: Create TopicsView  
                        Text("Topics - Coming Soon")
                            .navigationTitle("Topics")
                    }
                } header: {
                    Text("Explore GitLab")
                }
            }
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search projects, users, groups...")
        }
    }
}

// MARK: - Supporting Views

struct HomeFeatureRow<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
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
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthenticationStore())
} 