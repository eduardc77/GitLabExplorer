import SwiftUI
import GitLabNetwork

struct PersonalProjectsView: View {
    @State private var projectsStore: PersonalProjectsStore

    init(serviceFactory: ServiceFactory) {
        _projectsStore = State(initialValue: serviceFactory.createPersonalProjectsStore())
    }

    var body: some View {
        Group {
            if projectsStore.isEmpty && !projectsStore.isLoading {
                EmptyProjectsView() // Reusing the existing empty state view
            } else {
                ProjectsList(projectsStore: $projectsStore)
            }
        }
        .navigationTitle("Personal Projects")
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

private struct ProjectsList: View {
    @Binding var projectsStore: PersonalProjectsStore

    var body: some View {
        List(projectsStore.projects) { project in
            ProjectRowView(project: project) // Reusing ProjectRowView
        }
        .listStyle(.plain)
        .refreshable {
            await projectsStore.refresh()
        }
        .overlay {
            if projectsStore.isLoading && projectsStore.projects.isEmpty {
                ProgressView("Loading your projects...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    PersonalProjectsView(serviceFactory: ServiceFactory(configuration: GitLabConfiguration.fromInfoPlist(), authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))))
}