/// Provides authentication for Apollo GraphQL requests
public actor GitLabAuthProvider {
    private let tokenManager: TokenManager
    
    public init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    /// Get current authentication token for GraphQL requests
    public func getAuthToken() async throws -> String? {
        let token = try await tokenManager.getValidToken()
        return token.accessToken
    }
} 
