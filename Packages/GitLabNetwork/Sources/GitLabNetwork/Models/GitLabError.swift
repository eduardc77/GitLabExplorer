import Foundation

/// Comprehensive error types for GitLab Network layer
public enum GitLabError: Error, LocalizedError, Sendable {
    // OAuth errors
    case authorizationFailed(String)
    case invalidAuthorizationCode
    case noAuthToken
    case refreshTokenFailed(String)
    
    // Network errors
    case networkError(Error)
    case invalidURL(String)
    case noResponse
    case invalidResponse(String)
    case statusCode(Int, Data?)
    case httpError(statusCode: Int, message: String?)
    
    // Authentication errors
    case authenticationRequired
    case invalidCredentials
    case tokenExpired
    case tokenRefreshFailed
    
    // GraphQL errors
    case graphQLErrors([GraphQLErrorDetail])
    
    // Configuration errors
    case invalidConfiguration(String)
    
    // General errors
    case decodingError(String)
    case encodingError(String)
    case operationFailed(String)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .authorizationFailed(let message):
            return "Authorization failed: \(message)"
        case .invalidAuthorizationCode:
            return "Invalid authorization code"
        case .noAuthToken:
            return "No authentication token available"
        case .refreshTokenFailed(let message):
            return "Failed to refresh token: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .noResponse:
            return "No response received"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .statusCode(let code, _):
            return "HTTP status code: \(code)"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message ?? "Unknown error")"
        case .authenticationRequired:
            return "Authentication required"
        case .invalidCredentials:
            return "Invalid credentials"
        case .tokenExpired:
            return "Token expired"
        case .tokenRefreshFailed:
            return "Failed to refresh token"
        case .graphQLErrors(let errors):
            return "GraphQL errors: \(errors.map { $0.message }.joined(separator: ", "))"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

extension GitLabError {
    /// GraphQL error detail for Apollo integration
    public struct GraphQLErrorDetail: Sendable {
        public let message: String
        public let path: [String]
        public let extensions: [String: String]
        
        public init(message: String, path: [String] = [], extensions: [String: String] = [:]) {
            self.message = message
            self.path = path
            self.extensions = extensions
        }
        
        /// Internal initializer for Apollo integration
        internal init(message: String, path: [String], apolloExtensions: [String: Any]?) {
            self.message = message
            self.path = path
            // Convert [String: Any] to [String: String] safely
            self.extensions = apolloExtensions?.compactMapValues { value in
                if let stringValue = value as? String {
                    return stringValue
                } else {
                    return String(describing: value)
                }
            } ?? [:]
        }
    }
}

// MARK: - Equatable

extension GitLabError: Equatable {
    public static func == (lhs: GitLabError, rhs: GitLabError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let lhsURL), .invalidURL(let rhsURL)):
            return lhsURL == rhsURL
        case (.statusCode(let lhsCode, _), .statusCode(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.authenticationRequired, .authenticationRequired),
             (.invalidCredentials, .invalidCredentials),
             (.tokenExpired, .tokenExpired),
             (.tokenRefreshFailed, .tokenRefreshFailed),
             (.noResponse, .noResponse),
             (.noAuthToken, .noAuthToken),
             (.invalidAuthorizationCode, .invalidAuthorizationCode):
            return true
        default:
            return false
        }
    }
} 