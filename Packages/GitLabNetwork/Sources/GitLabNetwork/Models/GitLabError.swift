import Foundation

/// Errors that can occur when interacting with GitLab API
public enum GitLabError: LocalizedError, Sendable {
    // OAuth errors
    case authorizationFailed(String)
    case tokenExpired
    case refreshTokenFailed(String)
    case noAuthToken
    case invalidAuthorizationCode
    
    // Network errors
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    
    // GraphQL errors
    case graphQLErrors([GraphQLError])
    case noData
    
    // Configuration errors
    case invalidConfiguration(String)
    case invalidURL
    
    public var errorDescription: String? {
        switch self {
        case .authorizationFailed(let message):
            return "Authorization failed: \(message)"
        case .tokenExpired:
            return "Access token has expired"
        case .refreshTokenFailed(let message):
            return "Failed to refresh token: \(message)"
        case .noAuthToken:
            return "No authentication token available"
        case .invalidAuthorizationCode:
            return "Invalid authorization code"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message ?? "Unknown error")"
        case .graphQLErrors(let errors):
            let messages = errors.map { $0.message }.joined(separator: ", ")
            return "GraphQL errors: \(messages)"
        case .noData:
            return "No data received from server"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}

/// GraphQL error structure
public struct GraphQLError: Codable, Sendable {
    public let message: String
    public let path: [String]?
    public let extensions: [String: String]?
    
    public init(message: String, path: [String]? = nil, extensions: [String: String]? = nil) {
        self.message = message
        self.path = path
        self.extensions = extensions
    }
} 