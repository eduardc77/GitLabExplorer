import Foundation
@preconcurrency import Apollo
@preconcurrency import ApolloAPI

/// Apollo async/await extensions for Swift 6
/// Uses @preconcurrency and nonisolated(unsafe) to work around Apollo's non-Sendable types

extension ApolloClient {
    /// Fetch a GraphQL query with proper Swift 6 concurrency
    @Sendable
    func fetchAsync<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) async throws -> GraphQLResult<Query.Data> {
        return try await withCheckedThrowingContinuation { continuation in
            fetch(query: query, cachePolicy: cachePolicy) { result in
                // Use nonisolated(unsafe) to work around Apollo's non-Sendable Result type
                nonisolated(unsafe) let safeResult = result
                continuation.resume(with: safeResult)
            }
        }
    }
    
    /// Perform a GraphQL mutation with proper Swift 6 concurrency
    @Sendable
    func performAsync<Mutation: GraphQLMutation>(
        mutation: Mutation
    ) async throws -> GraphQLResult<Mutation.Data> {
        return try await withCheckedThrowingContinuation { continuation in
            perform(mutation: mutation) { result in
                // Use nonisolated(unsafe) to work around Apollo's non-Sendable Result type
                nonisolated(unsafe) let safeResult = result
                continuation.resume(with: safeResult)
            }
        }
    }
    
    /// Clear Apollo cache with proper Swift 6 concurrency
    @Sendable
    func clearCacheAsync() async throws {
        try await withCheckedThrowingContinuation { continuation in
            clearCache { result in
                continuation.resume(with: result)
            }
        }
    }
}

