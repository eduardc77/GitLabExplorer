import Foundation
import SwiftUI
import GitLabNetwork

@MainActor
@Observable
final class PersonalProjectsStore {
    public private(set) var projects: [ProjectSummary] = []
    public private(set) var isLoading = false
    public private(set) var error: GitLabError?

    private let personalProjectsService: PersonalProjectsServiceProtocol

    init(personalProjectsService: PersonalProjectsServiceProtocol) {
        self.personalProjectsService = personalProjectsService
    }

    func loadProjects() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            projects = try await personalProjectsService.getPersonalProjects()
        } catch {
            self.error = error as? GitLabError ?? GitLabError.unknown(error)
        }

        isLoading = false
    }

    func refresh() async {
        projects = []
        await loadProjects()
    }

    func clearError() {
        error = nil
    }

    var hasProjects: Bool {
        !projects.isEmpty
    }

    var isEmpty: Bool {
        !isLoading && projects.isEmpty
    }

    convenience init() {
        let configuration = GitLabConfiguration.preview()
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let personalProjectsService = PersonalProjectsService(configuration: configuration, authProvider: authProvider)
        self.init(personalProjectsService: personalProjectsService)
    }
}