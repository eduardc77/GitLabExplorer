import Foundation
@preconcurrency import Apollo
@preconcurrency import ApolloAPI

/// Request context for passing authentication token
private final class AuthContext: RequestContext {
    let token: String?
    
    init(token: String?) {
        self.token = token
    }
}

public actor GraphQLClient {
    private let apolloClient: ApolloClient
    private let configuration: GitLabConfiguration
    private let authProvider: GitLabAuthProvider
    
    public init(configuration: GitLabConfiguration, authProvider: GitLabAuthProvider) {
        self.configuration = configuration
        self.authProvider = authProvider
        
        // Setup Apollo client with custom interceptor provider
        let url = configuration.baseURL.appendingPathComponent("/api/graphql")
        let store = ApolloStore()
        let client = URLSessionClient()
        
        // Create interceptor provider
        let provider = AuthInterceptorProvider(client: client, store: store)
        
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        
        self.apolloClient = ApolloClient(
            networkTransport: transport,
            store: store
        )
    }
    
    // MARK: - Public API
    
    /// Get current authenticated user
    public func getCurrentUser() async throws -> GitLabUser? {
        let query = GitLabAPI.CurrentUserQuery()
        
        // Get auth token
        let token = try await authProvider.getAuthToken()
        let context = AuthContext(token: token)
        
        // Execute query with proper isolation
        let result: GraphQLResult<GitLabAPI.CurrentUserQuery.Data> = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(
                query: query,
                cachePolicy: .returnCacheDataElseFetch,
                contextIdentifier: nil,
                context: context,
                queue: .main
            ) { fetchResult in
                switch fetchResult {
                case .success(let graphQLResult):
                    continuation.resume(returning: graphQLResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Handle GraphQL errors
        if let errors = result.errors, !errors.isEmpty {
            throw GitLabError.graphQLErrors(errors.map { error in
                GitLabError.GraphQLErrorDetail(
                    message: error.message ?? "Unknown error",
                    path: error.path?.compactMap { "\($0)" } ?? [],
                    apolloExtensions: error.extensions
                )
            })
        }
        
        // Convert to domain model
        guard let apolloUser = result.data?.currentUser else {
            return nil
        }
        
        return GitLabUser(
            id: String(apolloUser.id),
            username: apolloUser.username,
            name: apolloUser.name,
            email: apolloUser.publicEmail,
            avatarUrl: apolloUser.avatarUrl.flatMap(URL.init),
            bio: apolloUser.bio,
            location: apolloUser.location,
            webUrl: URL(string: apolloUser.webUrl),
            createdAt: apolloUser.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            lastActivityOn: apolloUser.lastActivityOn.flatMap { ISO8601DateFormatter().date(from: $0) },
            state: UserState(rawValue: apolloUser.state.rawValue) ?? .active
        )
    }
    
    /// Search for users
    public func searchUsers(query: String, limit: Int = 20, after: String? = nil) async throws -> [GitLabUser] {
        let searchQuery = GitLabAPI.SearchUsersQuery(
            query: query,
            first: .some(limit),
            after: after.map { GraphQLNullable.some($0) } ?? .none
        )
        
        // Get auth token
        let token = try await authProvider.getAuthToken()
        let context = AuthContext(token: token)
        
        // Execute query with proper isolation
        let result: GraphQLResult<GitLabAPI.SearchUsersQuery.Data> = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(
                query: searchQuery,
                cachePolicy: .returnCacheDataElseFetch,
                contextIdentifier: nil,
                context: context,
                queue: .main
            ) { fetchResult in
                switch fetchResult {
                case .success(let graphQLResult):
                    continuation.resume(returning: graphQLResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Handle GraphQL errors
        if let errors = result.errors, !errors.isEmpty {
            throw GitLabError.graphQLErrors(errors.map { error in
                GitLabError.GraphQLErrorDetail(
                    message: error.message ?? "Unknown error",
                    path: error.path?.compactMap { "\($0)" } ?? [],
                    apolloExtensions: error.extensions
                )
            })
        }
        
        // Convert to domain models
        return result.data?.users?.edges?.compactMap { edge -> GitLabUser? in
            guard let node = edge?.node else { return nil }
            return GitLabUser.from(node.fragments.userDetails)
        } ?? []
    }
    
    /// Clear the Apollo cache
    public func clearCache() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            apolloClient.clearCache { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Auth Interceptor Provider

/// Custom interceptor provider that adds authentication
private final class AuthInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        // Insert auth interceptor at the beginning
        interceptors.insert(AuthTokenInterceptor(), at: 0)
        return interceptors
    }
}

// MARK: - Auth Token Interceptor

/// Interceptor that adds authentication token from request context
private final class AuthTokenInterceptor: ApolloInterceptor {
    let id = UUID().uuidString
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        // Get auth context from request
        if let authContext = request.context as? AuthContext,
           let token = authContext.token {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        
        // Continue with the chain
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
