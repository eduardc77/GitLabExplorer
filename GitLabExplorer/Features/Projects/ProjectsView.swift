//
//  ProjectsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct ProjectsView: View {
    @State private var projectsStore: ProjectsStore
    
    init(serviceFactory: ServiceFactory) {
        projectsStore = serviceFactory.createProjectsStore()
    }
    
    var body: some View {
        Group {
            if projectsStore.isEmpty && !projectsStore.isLoading {
                EmptyProjectsView()
            } else {
                ProjectsList(projectsStore: $projectsStore)
            }
        }
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await projectsStore.refresh()
        }
        .task {
            if !projectsStore.hasProjects {
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

// MARK: - Projects List with Infinite Scroll

private struct ProjectsList: View {
    @Binding var projectsStore: ProjectsStore
    
    var body: some View {
        List(projectsStore.projects) { project in
            ProjectRowView(project: project)
                .onAppear {
                    // Trigger infinite scroll when we reach the last few items
                    if shouldLoadMore(for: project) {
                        Task {
                            await projectsStore.loadMoreProjects()
                        }
                    }
                }
        }
        .listStyle(.plain)
        .refreshable {
            await projectsStore.refresh()
        }
        .overlay {
            if projectsStore.isLoading && projectsStore.projects.isEmpty {
                ProgressView("Loading projects...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if projectsStore.isLoadingMore {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(.regularMaterial, in: .rect(cornerRadius: 8))
                .padding()
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
    
    /// Determines if we should load more projects when this project appears
    private func shouldLoadMore(for project: ProjectSummary) -> Bool {
        guard projectsStore.hasNextPage && !projectsStore.isLoadingMore && !projectsStore.isLoading else {
            return false
        }
        
        // Load more when we're within the last 3 items
        guard let lastIndex = projectsStore.projects.lastIndex(where: { $0.id == project.id }),
              lastIndex >= projectsStore.projects.count - 3 else {
            return false
        }
        
        return true
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
    ProjectsView(serviceFactory: ServiceFactory(configuration: GitLabConfiguration.fromInfoPlist(), authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))))
}
