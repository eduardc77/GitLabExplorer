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
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
    }
}

/// Token refresh request
struct TokenRefreshRequest: Encodable {
    let clientID: String
    let refreshToken: String
    let grantType: String = "refresh_token"
    let redirectURI: String
    
    private enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case refreshToken = "refresh_token"
        case grantType = "grant_type"
        case redirectURI = "redirect_uri"
    }
}

/// Token exchange request for authorization code
struct TokenExchangeRequest: Encodable {
    let clientID: String
    let code: String
    let grantType: String = "authorization_code"
    let redirectURI: String
    let codeVerifier: String
    
    private enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case code = "code"
        case grantType = "grant_type"
        case redirectURI = "redirect_uri"
        case codeVerifier = "code_verifier"
    }
} 