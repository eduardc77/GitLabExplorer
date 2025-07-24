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
    
    /// Execute a GraphQL query with authentication and error handling
    public func executeQuery<Query: GraphQLQuery>(_ query: Query) async throws -> GraphQLResult<Query.Data> {
        // Get auth token
        let token = try await authProvider.getAuthToken()
        let context = AuthContext(token: token)
        
        // Execute query with proper isolation
        let result: GraphQLResult<Query.Data> = try await withCheckedThrowingContinuation { continuation in
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
        
        return result
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
