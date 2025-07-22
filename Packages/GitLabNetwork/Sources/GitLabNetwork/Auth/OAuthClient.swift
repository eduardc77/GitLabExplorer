import Foundation
import CryptoKit
import AuthenticationServices

/// Handles OAuth authentication flow for GitLab
public actor OAuthClient {
    private let configuration: GitLabConfiguration
    private let session: URLSession
    
    // PKCE (Proof Key for Code Exchange) parameters
    private var codeVerifier: String?
    private var state: String?
    
    public init(
        configuration: GitLabConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Start OAuth flow and return authorization URL
    public func createAuthorizationRequest() -> URL? {
        // Generate PKCE parameters
        let verifier = generateCodeVerifier()
        let challenge = generateCodeChallenge(from: verifier)
        let stateValue = generateState()
        
        // Store for later use
        self.codeVerifier = verifier
        self.state = stateValue
        
        // Use the configuration's helper method
        return configuration.oauth.authorizationURL(
            baseURL: configuration.baseURL,
            state: stateValue,
            codeChallenge: challenge
        )
    }
    
    /// Exchange authorization code for access token
    public func exchangeCodeForToken(code: String, state: String) async throws -> OAuthToken {
        // Verify state matches
        guard state == self.state else {
            throw GitLabError.authorizationFailed("State mismatch - possible CSRF attack")
        }
        
        guard let verifier = self.codeVerifier else {
            throw GitLabError.authorizationFailed("Missing code verifier")
        }
        
        // Build token request
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.path = configuration.oauth.endpoints.token
        
        guard let url = components?.url else {
            throw GitLabError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = TokenExchangeRequest(
            clientID: configuration.oauth.clientID,
            code: code,
            redirectURI: configuration.oauth.redirectURI,
            codeVerifier: verifier
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8)
            throw GitLabError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
        
        // Decode token
        let token = try JSONDecoder().decode(OAuthToken.self, from: data)
        
        // Clear PKCE parameters
        self.codeVerifier = nil
        self.state = nil
        
        return token
    }
    
    /// Refresh an expired token
    public func refreshToken(_ token: OAuthToken) async throws -> OAuthToken {
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.path = configuration.oauth.endpoints.token
        
        guard let url = components?.url else {
            throw GitLabError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = TokenRefreshRequest(
            clientID: configuration.oauth.clientID,
            refreshToken: token.refreshToken,
            redirectURI: configuration.oauth.redirectURI
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8)
            throw GitLabError.refreshTokenFailed(message ?? "Unknown error")
        }
        
        return try JSONDecoder().decode(OAuthToken.self, from: data)
    }
    
    // MARK: - PKCE Helpers
    
    private func generateCodeVerifier() -> String {
        let data = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return data.base64URLEncodedString()
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64URLEncodedString()
    }
    
    private func generateState() -> String {
        let data = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        return data.base64URLEncodedString()
    }
}

// MARK: - Data Extension for Base64 URL Encoding

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
} 