import Foundation
import Observation

/// Manages authentication state and coordinates OAuth flow
@Observable
public final class AuthenticationManager: Sendable {
    private let configuration: GitLabConfiguration
    private let tokenManager: TokenManager
    
    // Observable authentication state
    public private(set) var isAuthenticated = false
    public private(set) var currentUser: String?
    
    // Nonisolated properties for Sendable conformance
    nonisolated private let _tokenManager: TokenManager
    nonisolated private let _configuration: GitLabConfiguration
    
    public init(configuration: GitLabConfiguration) {
        self.configuration = configuration
        self._configuration = configuration
        self.tokenManager = TokenManager(configuration: configuration)
        self._tokenManager = tokenManager
        
        // Check initial auth state
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    // MARK: - Authentication
    
    /// Start OAuth authentication flow
    @MainActor
    public func authenticate() async throws {
        // 1. Get authorization URL
        guard let authURL = await _tokenManager.getOAuthClient().createAuthorizationRequest() else {
            throw GitLabError.invalidConfiguration("Failed to create authorization URL")
        }
        
        // 2. Open in browser (the app will handle this)
        // Return the URL so the app can open it
        await openAuthorizationURL(authURL)
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
        let token = try await _tokenManager.getOAuthClient().exchangeCodeForToken(
            code: code,
            state: state
        )
        
        // Save token
        try await _tokenManager.saveToken(token)
        
        // Update auth state
        await checkAuthenticationStatus()
    }
    
    /// Sign out and clear tokens
    public func signOut() async throws {
        try await _tokenManager.clearToken()
        
        await MainActor.run {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    /// Check if user is authenticated
    private func checkAuthenticationStatus() async {
        let authenticated = await _tokenManager.isAuthenticated()
        
        await MainActor.run {
            self.isAuthenticated = authenticated
            // TODO: Fetch current user info when GraphQL is set up
        }
    }
    
    /// Open authorization URL (to be implemented by the app)
    @MainActor
    private func openAuthorizationURL(_ url: URL) async {
        // This will be handled by the app using ASWebAuthenticationSession
        // For now, just print it
        print("Open this URL for authentication: \(url)")
    }
    
    // MARK: - API Access (placeholder for now)
    
    /// Get a valid access token for API calls
    public func getAccessToken() async throws -> String {
        let token = try await _tokenManager.getValidToken()
        return token.accessToken
    }
    
    // TODO: Add GraphQL client methods here
    // public func searchUsers(query: String) async throws -> [User]
    // public func getCurrentUser() async throws -> User
    // etc.
}

// MARK: - Authentication Completion Handler

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