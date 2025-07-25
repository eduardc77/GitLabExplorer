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
                    // Trigger infinite scroll when we reach near the end
                    if store.projects.last?.id == project.id {
                        Task {
                            await store.loadMoreProjects()
                        }
                    }
                }
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
    }
}

// MARK: - Real Project Row View

private struct RealProjectRowView: View {
    let project: GitLabProject
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: project.avatarUrl) { image in
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
                    
                    if let lastActivity = project.lastActivityAt {
                        Text("Updated \(lastActivity, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
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
