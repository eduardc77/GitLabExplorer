import XCTest
@testable import GitLabNetwork

// Mock storage for testing
final class MockTokenStorage: TokenStorage {
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

final class TokenManagerTests: XCTestCase {
    
    func testTokenStorage() async throws {
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
        let token = OAuthToken(
            accessToken: "test-access-token",
            tokenType: "Bearer",
            expiresIn: 7200,
            refreshToken: "test-refresh-token",
            createdAt: Int(Date().timeIntervalSince1970)
        )
        
        // Test save
        try await tokenManager.saveToken(token)
        
        // Test retrieve
        let retrievedToken = try await tokenManager.getValidToken()
        XCTAssertEqual(retrievedToken.accessToken, "test-access-token")
        
        // Test clear
        try await tokenManager.clearToken()
        
        // Should throw after clearing
        do {
            _ = try await tokenManager.getValidToken()
            XCTFail("Expected error after clearing token")
        } catch GitLabError.noAuthToken {
            // Expected
        }
    }
    
    func testAuthenticationCheck() async throws {
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
        XCTAssertFalse(isAuth)
        
        // Save a token
        let token = OAuthToken(
            accessToken: "test-token",
            tokenType: "Bearer",
            expiresIn: 7200,
            refreshToken: "refresh",
            createdAt: Int(Date().timeIntervalSince1970)
        )
        try await tokenManager.saveToken(token)
        
        // Now authenticated
        let isAuthAfter = await tokenManager.isAuthenticated()
        XCTAssertTrue(isAuthAfter)
    }
} 