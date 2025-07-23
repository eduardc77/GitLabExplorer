import Foundation
@preconcurrency import Apollo
@preconcurrency import ApolloAPI

/// GraphQL client for GitLab API with Swift 6 concurrency
/// Contains business logic to convert Apollo types to domain models inside the actor
public actor GraphQLClient {
    private let apolloClient: ApolloClient
    private let configuration: GitLabConfiguration
    
    public init(configuration: GitLabConfiguration, authProvider: GitLabAuthProvider) {
        self.configuration = configuration
        
        // Initialize Apollo client with proper configuration
        let store = ApolloStore()
        let client = URLSessionClient()
        let provider = DefaultInterceptorProvider(client: client, store: store)
        
        let url = configuration.baseURL.appendingPathComponent("/api/graphql")
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        
        self.apolloClient = ApolloClient(networkTransport: transport, store: store)
    }
    
    // MARK: - Raw GraphQL Operations (for internal use)
    
    /// Execute a GraphQL query and return raw Apollo data (internal use only)
    private func queryRaw<Query: GraphQLQuery>(
        _ query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) async throws -> Query.Data {
        // Capture safely to avoid actor isolation issues
        nonisolated(unsafe) let safeQuery = query
        nonisolated(unsafe) let safeCachePolicy = cachePolicy
        let result = try await apolloClient.fetchAsync(query: safeQuery, cachePolicy: safeCachePolicy)
        
        // Handle GraphQL errors
        if let errors = result.errors, !errors.isEmpty {
            let errorDetails = errors.map { error in
                GitLabError.GraphQLErrorDetail(
                    message: error.message ?? "Unknown GraphQL error",
                    path: error.path?.compactMap { "\($0)" } ?? [],
                    apolloExtensions: error.extensions
                )
            }
            throw GitLabError.graphQLErrors(errorDetails)
        }
        
        guard let data = result.data else {
            throw GitLabError.invalidResponse("No data in GraphQL response")
        }
        
        return data
    }
    
    /// Execute a GraphQL mutation and return raw Apollo data (internal use only)
    private func mutateRaw<Mutation: GraphQLMutation>(
        _ mutation: Mutation
    ) async throws -> Mutation.Data {
        // Capture safely to avoid actor isolation issues
        nonisolated(unsafe) let safeMutation = mutation
        let result = try await apolloClient.performAsync(mutation: safeMutation)
        
        // Handle GraphQL errors
        if let errors = result.errors, !errors.isEmpty {
            let errorDetails = errors.map { error in
                GitLabError.GraphQLErrorDetail(
                    message: error.message ?? "Unknown GraphQL error",
                    path: error.path?.compactMap { "\($0)" } ?? [],
                    apolloExtensions: error.extensions
                )
            }
            throw GitLabError.graphQLErrors(errorDetails)
        }
        
        guard let data = result.data else {
            throw GitLabError.invalidResponse("No data in GraphQL response")
        }
        
        return data
    }
    
    // MARK: - Domain-Specific Operations
    
    /// Get current user information
    public func getCurrentUser() async throws -> GitLabUser? {
        let query = GitLabAPI.CurrentUserQuery()
        let data = try await queryRaw(query)
        
        guard let apolloUser = data.currentUser else {
            return nil
        }
        
        // Convert Apollo type to domain model inside the actor
        return GitLabUser(
            id: String(apolloUser.id),
            username: apolloUser.username,
            name: apolloUser.name,
            email: apolloUser.publicEmail,
            avatarUrl: apolloUser.avatarUrl.flatMap(URL.init),
            bio: apolloUser.bio,
            location: apolloUser.location,
            webUrl: URL(string: apolloUser.webUrl),
            createdAt: apolloUser.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) }
        )
    }
    
    /// Search for users
    public func searchUsers(query: String, limit: Int = 20, after: String? = nil) async throws -> [GitLabUser] {
        let searchQuery = GitLabAPI.SearchUsersQuery(
            query: query,
            first: .some(limit),
            after: after.map { GraphQLNullable.some($0) } ?? .none
        )
        let data = try await queryRaw(searchQuery)
        
        // Convert Apollo types to domain models inside the actor
        let users = data.users?.edges?.compactMap { edge -> GitLabUser? in
            guard let node = edge?.node else { return nil }
            return GitLabUser.from(node.fragments.userDetails)
        } ?? []
        
        return users
    }
    
    // MARK: - Cache Management
    
    /// Clear Apollo cache
    public func clearCache() async throws {
        try await apolloClient.clearCacheAsync()
    }
} 
