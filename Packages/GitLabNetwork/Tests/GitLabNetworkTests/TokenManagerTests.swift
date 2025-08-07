import Testing
@testable import GitLabNetwork
import Foundation

// Mock storage for testing
actor MockTokenStorage: TokenStorage {
    private var storedToken: OAuthToken?
    
    func saveToken(_ token: OAuthToken) async throws {
        storedToken = token
    }
    
    func loadToken() async throws -> OAuthToken? {
        return storedToken
    }
    
    func deleteToken() async throws {
        storedToken = nil
    }
}

struct TokenManagerTests {
    
    // Helper function to create test tokens
    private func createTestToken(
        accessToken: String = "test-access-token",
        expiresIn: Int = 7200
    ) throws -> OAuthToken {
        let tokenData = """
        {
            "accessToken": "\(accessToken)",
            "tokenType": "Bearer",
            "expiresIn": \(expiresIn),
            "refreshToken": "test-refresh-token",
            "createdAt": \(Int(Date().timeIntervalSince1970))
        }
        """.data(using: .utf8)!
        
        return try JSONDecoder().decode(OAuthToken.self, from: tokenData)
    }
    
    @Test func testTokenStorage() async throws {
        // Setup
        let config = GitLabConfiguration(
            clientID: "test-client",
            redirectURI: "test://callback"
        )
        let mockStorage = MockTokenStorage()
        let tokenManager = TokenManager(
            configuration: config,
            storage: mockStorage
        )
        
        // Create a test token
        let token = try createTestToken()
        
        // Test save
        try await tokenManager.saveToken(token)
        
        // Test retrieve
        let retrievedToken = try await tokenManager.getValidToken()
        #expect(retrievedToken.accessToken == "test-access-token")
        
        // Test clear
        try await tokenManager.clearToken()
        
        // Should throw after clearing
        do {
            _ = try await tokenManager.getValidToken()
            #expect(Bool(false), "Expected error after clearing token")
        } catch GitLabError.noAuthToken {
            // Expected
        }
    }
    
    @Test func testAuthenticationCheck() async throws {
        let config = GitLabConfiguration(
            clientID: "test-client",
            redirectURI: "test://callback"
        )
        let mockStorage = MockTokenStorage()
        let tokenManager = TokenManager(
            configuration: config,
            storage: mockStorage
        )
        
        // Not authenticated initially
        let isAuth = await tokenManager.isAuthenticated()
        #expect(!isAuth)
        
        // Save a token
        let token = try createTestToken(accessToken: "test-token")
        try await tokenManager.saveToken(token)
        
        // Now authenticated
        let isAuthAfter = await tokenManager.isAuthenticated()
        #expect(isAuthAfter)
    }
    
    @Test func testTokenExpiration() async throws {
        let config = GitLabConfiguration(
            clientID: "test-client",
            redirectURI: "test://callback"
        )
        let mockStorage = MockTokenStorage()
        let tokenManager = TokenManager(
            configuration: config,
            storage: mockStorage
        )
        
        // Create an expired token (expires in 1 second)
        let expiredToken = try createTestToken(expiresIn: 1)
        try await tokenManager.saveToken(expiredToken)
        
        // Wait for token to expire
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Token should be expired
        #expect(expiredToken.isExpired())
        
        // Authentication should fail with expired token
        let isAuth = await tokenManager.isAuthenticated()
        #expect(!isAuth)
    }
} 
