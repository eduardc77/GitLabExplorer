import Foundation
import KeychainAccess

/// Protocol for token storage
public protocol TokenStorage: Sendable {
    func saveToken(_ token: OAuthToken) async throws
    func loadToken() async throws -> OAuthToken?
    func deleteToken() async throws
}

/// Manages OAuth tokens with secure storage and automatic refresh
public actor TokenManager {
    private let configuration: GitLabConfiguration
    private let oauthClient: OAuthClient
    private let storage: TokenStorage
    
    // Cached token
    private var currentToken: OAuthToken?
    
    public init(
        configuration: GitLabConfiguration,
        storage: TokenStorage? = nil
    ) {
        self.configuration = configuration
        self.oauthClient = OAuthClient(configuration: configuration)
        self.storage = storage ?? KeychainTokenStorage(
            service: "com.gitlabexplorer.oauth",
            account: configuration.oauth.clientID
        )
    }
    
    // MARK: - Public Methods
    
    /// Get a valid access token, refreshing if necessary
    public func getValidToken() async throws -> OAuthToken {
        // Load from cache or storage
        if currentToken == nil {
            currentToken = try await storage.loadToken()
        }
        
        guard let token = currentToken else {
            throw GitLabError.noAuthToken
        }
        
        // Check if token needs refresh
        if token.isExpired() {
            let refreshedToken = try await oauthClient.refreshToken(token)
            try await storage.saveToken(refreshedToken)
            currentToken = refreshedToken
            return refreshedToken
        }
        
        return token
    }
    
    /// Store a new token (after initial auth)
    public func saveToken(_ token: OAuthToken) async throws {
        try await storage.saveToken(token)
        currentToken = token
    }
    
    /// Clear stored tokens (logout)
    public func clearToken() async throws {
        try await storage.deleteToken()
        currentToken = nil
    }
    
    /// Check if user is authenticated
    public func isAuthenticated() async -> Bool {
        do {
            _ = try await getValidToken()
            return true
        } catch {
            return false
        }
    }
    
    /// Get OAuth client for initial authentication
    public func getOAuthClient() -> OAuthClient {
        return oauthClient
    }
}

// MARK: - Keychain Token Storage

/// Default implementation using KeychainAccess
public final class KeychainTokenStorage: TokenStorage {
    private let keychain: Keychain
    private let tokenKey = "gitlab_oauth_token"
    
    public init(service: String, account: String) {
        self.keychain = Keychain(service: service)
            .label("GitLab Explorer OAuth Token")
            .accessibility(.whenUnlockedThisDeviceOnly)
            .synchronizable(false)
    }
    
    public func saveToken(_ token: OAuthToken) async throws {
        let data = try JSONEncoder().encode(token)
        try keychain.set(data, key: tokenKey)
    }
    
    public func loadToken() async throws -> OAuthToken? {
        guard let data = try keychain.getData(tokenKey) else {
            return nil
        }
        return try JSONDecoder().decode(OAuthToken.self, from: data)
    }
    
    public func deleteToken() async throws {
        try keychain.remove(tokenKey)
    }
} 