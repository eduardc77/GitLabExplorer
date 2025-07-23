import Foundation
import KeychainAccess

/// Default implementation using KeychainAccess
public actor KeychainTokenStorage: TokenStorage {
    private let keychain: Keychain
    private let tokenKey = "gitlab_oauth_token"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(service: String, account: String) {
        self.keychain = Keychain(service: service)
            .label("GitLab Explorer OAuth Token")
            .accessibility(.whenUnlockedThisDeviceOnly)
            .synchronizable(false)
    }
    
    public func saveToken(_ token: OAuthToken) async throws {
        let data = try encoder.encode(token)
        try keychain.set(data, key: tokenKey)
    }
    
    public func loadToken() async throws -> OAuthToken? {
        guard let data = try keychain.getData(tokenKey) else {
            return nil
        }
        return try decoder.decode(OAuthToken.self, from: data)
    }
    
    public func deleteToken() async throws {
        try keychain.remove(tokenKey)
    }
} 
