import Foundation
@preconcurrency import Apollo

/// Service for handling GitLab authentication
public final class AuthenticationService: Sendable {
    private let configuration: GitLabConfiguration
    private let tokenManager: TokenManager
    private let graphQLClient: GraphQLClient

    public init(configuration: GitLabConfiguration, graphQLClient: GraphQLClient) {
        self.configuration = configuration
        self.tokenManager = TokenManager(configuration: configuration)
        self.graphQLClient = graphQLClient
    }

    // MARK: - Authentication Flow
    
    /// Generate OAuth authorization URL
    public func authenticate() async throws -> URL {
        // Generate and return authorization URL
        let authURL = try await tokenManager.getOAuthClient().generateAuthorizationURL()
        return authURL
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
    }
    
    /// Sign out and clear tokens
    public func signOut() async throws {
        try await tokenManager.clearToken()
    }
    
    // MARK: - Authentication State
    
    /// Check if user is currently authenticated
    public var isAuthenticated: Bool {
        get async {
            await tokenManager.isAuthenticated()
        }
    }
    
    /// Get current authenticated user
    public func getCurrentUser() async throws -> GitLabUser? {
        guard await isAuthenticated else {
            throw GitLabError.authenticationRequired
        }
        
        let query = GitLabAPI.CurrentUserQuery()
        let result = try await graphQLClient.executeQuery(query)
        
        // Convert to domain model
        guard let apolloUser = result.data?.currentUser else {
            return nil
        }
        
        return GitLabUser(
            id: String(apolloUser.id),
            username: apolloUser.username,
            name: apolloUser.name,
            email: apolloUser.publicEmail,
            avatarUrl: apolloUser.avatarUrl.flatMap(URL.init),
            bio: apolloUser.bio,
            location: apolloUser.location,
            webUrl: URL(string: apolloUser.webUrl),
            createdAt: apolloUser.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            lastActivityOn: apolloUser.lastActivityOn.flatMap { ISO8601DateFormatter().date(from: $0) },
            state: UserState(rawValue: apolloUser.state.rawValue) ?? .active
        )
    }
    
    /// Get a valid access token for API calls
    public func getAccessToken() async throws -> String {
        let token = try await tokenManager.getValidToken()
        return token.accessToken
    }
}

// MARK: - Authentication Helpers

public extension AuthenticationService {
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
