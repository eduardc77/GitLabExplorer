import Foundation

/// Configuration for GitLab API client
public struct GitLabConfiguration: Sendable {
    /// GitLab instance URL
    public let baseURL: URL
    
    /// OAuth configuration
    public let oauth: OAuthConfiguration
    
    /// GraphQL endpoint path
    public let graphQLPath: String
    
    /// API version for REST endpoints
    public let apiVersion: String
    
    public init(
        baseURL: URL = URL(string: "https://gitlab.com")!,
        clientID: String,
        redirectURI: String,
        scopes: [String] = ["read_user", "read_api", "read_repository"],
        graphQLPath: String = "/api/graphql",
        apiVersion: String = "v4"
    ) {
        self.baseURL = baseURL
        self.oauth = OAuthConfiguration(
            clientID: clientID,
            redirectURI: redirectURI,
            scopes: scopes
        )
        self.graphQLPath = graphQLPath
        self.apiVersion = apiVersion
    }
}

/// OAuth specific configuration
public struct OAuthConfiguration: Sendable {
    public let clientID: String
    public let redirectURI: String
    public let scopes: [String]
    
    /// OAuth endpoints
    public struct Endpoints: Sendable {
        public let authorize = "/oauth/authorize"
        public let token = "/oauth/token"
        public let revoke = "/oauth/revoke"
    }
    
    public let endpoints = Endpoints()
    
    /// Computed authorization URL with PKCE
    public func authorizationURL(baseURL: URL, state: String, codeChallenge: String) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path = endpoints.authorize
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        return components?.url
    }
} 
