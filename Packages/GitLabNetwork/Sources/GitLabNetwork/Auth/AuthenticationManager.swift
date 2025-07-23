import Foundation
import Apollo

@MainActor
@Observable
public final class AuthenticationManager {
    private let configuration: GitLabConfiguration
    private let tokenManager: TokenManager
    private let graphQLClient: GraphQLClient

    public private(set) var isAuthenticated = false
    public private(set) var currentUser: GitLabUser?
    public private(set) var isLoadingUser = false
    
    /// Initialize with shared GraphQL client (recommended pattern)
    public init(configuration: GitLabConfiguration, graphQLClient: GraphQLClient) {
        self.configuration = configuration
        self.tokenManager = TokenManager(configuration: configuration)
        self.graphQLClient = graphQLClient
        
        // Check initial auth state
        Task {
            await checkAuthenticationStatus()
        }
    }

    // MARK: - Authentication Flow
    
    /// Start OAuth authentication flow
    public func authenticate() async throws {
        // Generate authorization URL
        let authURL = try await tokenManager.getOAuthClient().generateAuthorizationURL()

        print("Open this URL to authenticate: \(authURL)")
    }
    
    /// Complete authentication with callback URL
    public func handleAuthCallback(url: URL) async throws {
        // Extract code and state from callback URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let state = components.queryItems?.first(where: { $0.name == "state" })?.value else {
            throw GitLabError.invalidAuthorizationCode
        }
        
        // Exchange code for token
        let token = try await tokenManager.getOAuthClient().exchangeCodeForToken(
            code: code,
            state: state
        )

        try await tokenManager.saveToken(token)
        await checkAuthenticationStatus()
    }
    
    /// Sign out and clear tokens
    public func signOut() async throws {
        try await tokenManager.clearToken()
        
        // Clear auth state AND current user together
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Current User Management
    
    /// Load the current authenticated user (part of auth flow)
    nonisolated public func loadCurrentUser() async throws {
        guard await isAuthenticated else {
            throw GitLabError.authenticationRequired
        }

        await MainActor.run { isLoadingUser = true }
        defer { Task { @MainActor in isLoadingUser = false } }
        
        do {
            let user = try await graphQLClient.getCurrentUser()
            await MainActor.run { currentUser = user }
        } catch {
            print("Error loading current user: \(error)")
            await MainActor.run { currentUser = nil }
            throw error
        }
    }
    
    /// Check if user is authenticated and load current user if needed
    private func checkAuthenticationStatus() async {
        let authenticated = await tokenManager.isAuthenticated()
        
        isAuthenticated = authenticated
        
        if authenticated && currentUser == nil {
            // Try to load current user automatically
            try? await loadCurrentUser()
        }
    }
    
    /// Get a valid access token for API calls
    public func getAccessToken() async throws -> String {
        let token = try await tokenManager.getValidToken()
        return token.accessToken
    }
    
    /// Get current user information
    public func getCurrentUser() async throws -> GitLabUser? {
        guard isAuthenticated else {
            throw GitLabError.authenticationRequired
        }
        
        do {
            return try await graphQLClient.getCurrentUser()
        } catch {
            // If we get an auth error, the token might be invalid
            if case GitLabError.authenticationRequired = error {
                try? await tokenManager.clearToken()
                await updateAuthenticationState(isAuthenticated: false, currentUser: nil)
            }
            throw error
        }
    }
    
    /// Update authentication state on main actor
    private func updateAuthenticationState(isAuthenticated: Bool, currentUser: GitLabUser?) async {
        await MainActor.run {
            self.isAuthenticated = isAuthenticated
            self.currentUser = currentUser
        }
    }
}

// MARK: - Authentication Helpers

public extension AuthenticationManager {
    /// Helper to validate callback URL
    static func isAuthCallback(url: URL, redirectURI: String) -> Bool {
        // Check if the URL matches our redirect URI
        guard let redirectURL = URL(string: redirectURI),
              url.scheme == redirectURL.scheme,
              url.host == redirectURL.host,
              url.path == redirectURL.path else {
            return false
        }
        
        // Check if it has code parameter
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.contains(where: { $0.name == "code" }) ?? false
    }
}
