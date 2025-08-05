/// Provides authentication for Apollo GraphQL requests
public actor GitLabAuthProvider {
    private let tokenManager: TokenManager
    
    public init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    /// Get current authentication token for GraphQL requests
    /// Returns nil if no valid token is available (for public API access)
    public func getAuthToken() async -> String? {
        do {
            let token = try await tokenManager.getValidToken()
            return token.accessToken
        } catch {
            // No token available - this is fine for public API access
            return nil
        }
    }
    
    /// Check if user is currently authenticated
    public func isAuthenticated() async -> Bool {
        do {
            _ = try await tokenManager.getValidToken()
            return true
        } catch {
            return false
        }
    }
} 
