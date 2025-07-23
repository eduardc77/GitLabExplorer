import Foundation
import CryptoKit

/// Handles OAuth authentication flow for GitLab
public actor OAuthClient {
    private let configuration: GitLabConfiguration
    private let session = URLSession.shared
    private var state: String?
    private var codeVerifier: String?

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    public init(configuration: GitLabConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Authorization URL Generation
    
    public func generateAuthorizationURL() throws -> URL {
        // Generate PKCE parameters
        let verifier = generateCodeVerifier()
        let challenge = generateCodeChallenge(from: verifier)
        let state = generateState()
        
        // Store for later verification
        self.codeVerifier = verifier
        self.state = state
        
        // Build authorization URL
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.path = configuration.oauth.endpoints.authorize
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.oauth.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.oauth.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.oauth.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        guard let url = components?.url else {
            throw GitLabError.invalidURL("Failed to create authorization URL")
        }
        
        return url
    }
    
    // MARK: - Token Exchange
    
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
            throw GitLabError.invalidURL("Failed to create token URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let tokenRequest = TokenRequest(
            clientId: configuration.oauth.clientID,
            code: code,
            redirectUri: configuration.oauth.redirectURI,
            codeVerifier: verifier
        )
        
        request.httpBody = try encoder.encode(tokenRequest)
        
        // Execute request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabError.invalidResponse("Invalid response type")
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8)
            throw GitLabError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
        
        return try decoder.decode(OAuthToken.self, from: data)
    }
    
    // MARK: - Token Refresh
    
    public func refreshToken(_ refreshToken: String) async throws -> OAuthToken {
        // Build refresh request
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.path = configuration.oauth.endpoints.token
        
        guard let url = components?.url else {
            throw GitLabError.invalidURL("Failed to create refresh token URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let refreshRequest = RefreshTokenRequest(
            clientId: configuration.oauth.clientID,
            refreshToken: refreshToken
        )
        
        request.httpBody = try encoder.encode(refreshRequest)
        
        // Execute request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabError.invalidResponse("Invalid response type for refresh token")
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8)
            throw GitLabError.refreshTokenFailed(message ?? "Unknown error")
        }
        
        return try decoder.decode(OAuthToken.self, from: data)
    }
}

// MARK: - Private Helpers

private extension OAuthClient {
    func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
    
    func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64URLEncodedString()
    }
    
    func generateState() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
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

// MARK: - Request Models

private struct TokenRequest: Encodable {
    let grantType = "authorization_code"
    let clientId: String
    let code: String
    let redirectUri: String
    let codeVerifier: String
}

private struct RefreshTokenRequest: Encodable {
    let grantType = "refresh_token"
    let clientId: String
    let refreshToken: String
} 
