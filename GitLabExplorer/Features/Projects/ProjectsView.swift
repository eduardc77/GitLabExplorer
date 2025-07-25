//
//  ProjectsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    @Environment(AuthenticationStore.self) private var authStore
    
    @State private var showingFilters = false
    @State private var showingSortOptions = false
    
    var body: some View {
        NavigationStack {
            Group {
                if projectsStore.showErrorState {
                    ErrorStateView(
                        error: projectsStore.error,
                        retryAction: {
                            Task {
                                await projectsStore.loadProjects()
                            }
                        }
                    )
                } else if projectsStore.showEmptyState {
                    EmptyStateView()
                } else {
                    ProjectsListView()
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: Binding(
                    get: { projectsStore.searchText },
                    set: { newValue in
                        Task {
                            await projectsStore.searchProjects(query: newValue)
                        }
                    }
                ),
                prompt: "Search projects..."
            )
            .refreshable {
                await projectsStore.refreshProjects()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingSortOptions = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                ProjectFiltersView()
            }
            .confirmationDialog("Sort Projects", isPresented: $showingSortOptions) {
                SortOptionsView()
            }
            .task {
                if projectsStore.projects.isEmpty {
                    await projectsStore.loadProjects()
                }
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        projectsStore.selectedFilter != .all ||
        projectsStore.selectedVisibility != nil ||
        projectsStore.showArchivedProjects
    }
}

// MARK: - Projects List View

struct ProjectsListView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    
    var body: some View {
        List {
            // Filter Summary
            if projectsStore.selectedFilter != .all {
                FilterSummaryView()
            }
            
            // Projects
            ForEach(projectsStore.filteredProjects) { project in
                NavigationLink(value: project) {
                    ProjectRowView(project: project)
                }
                .listRowSeparator(.hidden)
                .onAppear {
                    if projectsStore.shouldLoadMore(for: project) {
                        Task {
                            await projectsStore.loadMoreProjects()
                        }
                    }
                }
            }
            
            // Loading More Indicator
            if projectsStore.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .overlay {
            if projectsStore.isLoading {
                ProgressView("Loading projects...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Filter Summary View

struct FilterSummaryView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: projectsStore.selectedFilter.iconName)
                    .foregroundColor(.blue)
                
                Text(projectsStore.selectedFilter.displayName)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let totalProjects = projectsStore.totalProjects {
                    Text("\(totalProjects) projects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !projectsStore.searchText.isEmpty {
                Text("Search: \"\(projectsStore.searchText)\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Projects Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !projectsStore.searchText.isEmpty {
                Button("Clear Search") {
                    Task {
                        await projectsStore.searchProjects(query: "")
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateMessage: String {
        if !projectsStore.searchText.isEmpty {
            return "No projects match your search criteria. Try adjusting your search terms or filters."
        } else {
            switch projectsStore.selectedFilter {
            case .all:
                return "You don't have access to any projects yet."
            case .owned:
                return "You haven't created any projects yet."
            case .starred:
                return "You haven't starred any projects yet."
            case .membership:
                return "You're not a member of any projects yet."
            }
        }
    }
}

// MARK: - Error State View

struct ErrorStateView: View {
    let error: Error?
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Unable to Load Projects")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(error?.localizedDescription ?? "An unexpected error occurred.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Project Filters View

struct ProjectFiltersView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project Type") {
                    ForEach(ProjectsStore.ProjectFilter.allCases, id: \.rawValue) { filter in
                        Button {
                            Task {
                                await projectsStore.updateFilter(filter)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: filter.iconName)
                                    .foregroundColor(.blue)
                                
                                Text(filter.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if projectsStore.selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Visibility") {
                    Button {
                        Task {
                            await projectsStore.updateVisibility(nil)
                        }
                    } label: {
                        HStack {
                            Text("All Visibilities")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if projectsStore.selectedVisibility == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(ProjectVisibility.allCases, id: \.rawValue) { visibility in
                        Button {
                            Task {
                                await projectsStore.updateVisibility(visibility)
                            }
                        } label: {
                            HStack {
                                Image(systemName: visibility.iconName)
                                    .foregroundColor(.secondary)
                                
                                Text(visibility.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if projectsStore.selectedVisibility == visibility {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Options") {
                    Toggle("Show Archived Projects", isOn: Binding(
                        get: { projectsStore.showArchivedProjects },
                        set: { _ in
                            Task {
                                await projectsStore.toggleArchivedProjects()
                            }
                        }
                    ))
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Sort Options View

struct SortOptionsView: View {
    @Environment(ProjectsStore.self) private var projectsStore
    
    var body: some View {
        ForEach(ProjectListParameters.ProjectOrderBy.allCases, id: \.rawValue) { orderBy in
            Button {
                Task {
                    await projectsStore.updateSortOrder(orderBy, direction: .desc)
                }
            } label: {
                HStack {
                    Text("Sort by \(orderBy.displayName)")
                    
                    if projectsStore.sortOrder == orderBy {
                        Spacer()
                        Image(systemName: projectsStore.sortDirection == .desc ? "arrow.down" : "arrow.up")
                    }
                }
            }
        }
        
        Button("Cancel", role: .cancel) { }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProjectsView()
    }
    .environment(ProjectsStore.mock())
    .environment(AuthenticationStore())
}
