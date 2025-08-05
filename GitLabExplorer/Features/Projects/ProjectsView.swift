//
//  ProjectsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct ProjectsView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    
    var body: some View {
        NavigationStack {
            Group {
                if projectsStore.isEmpty && !projectsStore.isLoading {
                    EmptyProjectsView()
                } else {
                    ProjectsList()
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await projectsStore.refresh()
            }
            .task {
                if projectsStore.projects.isEmpty {
                    await projectsStore.loadProjects()
                }
            }
            .alert("Error", isPresented: .constant(projectsStore.error != nil)) {
                Button("OK") {
                    projectsStore.clearError()
                }
            } message: {
                if let error = projectsStore.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Projects List with Infinite Scroll

private struct ProjectsList: View {
    @Environment(ProjectsStore.self) private var store
    
    var body: some View {
        List(store.projects) { project in
            RealProjectRowView(project: project)
                .onAppear {
                    // Trigger infinite scroll when we reach the last few items
                    if shouldLoadMore(for: project) {
                        Task {
                            await store.loadMoreProjects()
                        }
                    }
                }
        }
        .refreshable {
            await store.refresh()
        }
        .overlay {
            if store.isLoading && store.projects.isEmpty {
                ProgressView("Loading projects...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if store.isLoadingMore {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding()
            }
        }
        .alert("Error", isPresented: .constant(store.error != nil)) {
            Button("OK") {
                store.clearError()
            }
        } message: {
            if let error = store.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    /// Determines if we should load more projects when this project appears
    private func shouldLoadMore(for project: ProjectSummary) -> Bool {
        guard store.hasNextPage && !store.isLoadingMore && !store.isLoading else {
            return false
        }
        
        // Load more when we're within the last 3 items
        guard let lastIndex = store.projects.lastIndex(where: { $0.id == project.id }),
              lastIndex >= store.projects.count - 3 else {
            return false
        }
        
        return true
    }
}

// MARK: - Real Project Row View

private struct RealProjectRowView: View {
    let project: ProjectSummary
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: project.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.gradient)
                    .overlay {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = project.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    Label("\(project.starCount)", systemImage: "star")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label("\(project.forkCount)", systemImage: "tuningfork")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Updated \(timeAgoText(from: project.updatedAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    /// Format time ago text in a user-friendly way without constantly updating seconds
    private func timeAgoText(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        let weeks = Int(timeInterval / 604800)
        let months = Int(timeInterval / 2629746)
        let years = Int(timeInterval / 31556952)
        
        if years > 0 {
            return "\(years)y ago"
        } else if months > 0 {
            return "\(months)mo ago"
        } else if weeks > 0 {
            return "\(weeks)w ago"
        } else if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
}

// MARK: - Empty State

private struct EmptyProjectsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Projects", systemImage: "folder.badge.questionmark")
        } description: {
            Text("No projects found. Try refreshing or check your connection.")
        }
    }
}

#Preview {
    ProjectsView()
        .environment(ProjectsStore())
        .environment(AuthenticationStore())
}
