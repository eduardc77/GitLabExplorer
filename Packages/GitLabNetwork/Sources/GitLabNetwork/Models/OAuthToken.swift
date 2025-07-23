import Foundation

/// OAuth token response from GitLab
public struct OAuthToken: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String
    public let createdAt: Int
    
    /// Computed expiry date
    public var expiryDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt + expiresIn))
    }
    
    /// Check if token is expired with a buffer
    public func isExpired(buffer: TimeInterval = 300) -> Bool {
        expiryDate.timeIntervalSinceNow < buffer
    }
}

/// Token refresh request
struct TokenRefreshRequest: Encodable {
    let clientId: String
    let refreshToken: String
    let grantType: String = "refresh_token"
    let redirectUri: String
}

/// Token exchange request for authorization code
struct TokenExchangeRequest: Encodable {
    let clientId: String
    let code: String
    let grantType: String = "authorization_code"
    let redirectUri: String
    let codeVerifier: String
} 