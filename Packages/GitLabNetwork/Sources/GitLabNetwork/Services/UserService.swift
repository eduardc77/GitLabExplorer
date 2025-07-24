import Foundation
@preconcurrency import Apollo

/// Service for user operations (OTHER users, not current user)
/// Current user is managed by AuthenticationService
public final class UserService: Sendable {
    
    // MARK: - Properties
    
    private let graphQLClient: GraphQLClient
    
    // MARK: - Initialization
    
    /// Initialize with existing GraphQL client
    public init(graphQLClient: GraphQLClient) {
        self.graphQLClient = graphQLClient
    }
    
    // MARK: - User Search Operations
    
    /// Search for users
    public func searchUsers(query: String, limit: Int = 20) async throws -> [GitLabUser] {
        let searchQuery = GitLabAPI.SearchUsersQuery(
            query: query,
            first: .some(limit),
            after: .none
        )
        
        let result = try await graphQLClient.executeQuery(searchQuery)
        
        // Convert to domain models
        return result.data?.users?.edges?.compactMap { edge -> GitLabUser? in
            guard let node = edge?.node else { return nil }
            return GitLabUser.from(node.fragments.userDetails)
        } ?? []
    }
    
    /// Get user profile by ID
    public func getUserProfile(id: String) async throws -> GitLabUser? {
        // TODO: Create GetUser.graphql query
        throw GitLabError.invalidConfiguration("GetUser query not implemented yet")
    }
    
    /// Get user by username
    public func getUserByUsername(username: String) async throws -> GitLabUser? {
        // TODO: Create GetUserByUsername.graphql query
        throw GitLabError.invalidConfiguration("GetUserByUsername query not implemented yet")
    }
    
    // MARK: - User Actions (TODO)
    
    /// Follow a user
    public func followUser(userId: String) async throws {
        // TODO: Create FollowUser.graphql mutation
        throw GitLabError.invalidConfiguration("FollowUser mutation not implemented yet")
    }
    
    /// Unfollow a user
    public func unfollowUser(userId: String) async throws {
        // TODO: Create UnfollowUser.graphql mutation
        throw GitLabError.invalidConfiguration("UnfollowUser mutation not implemented yet")
    }
}

 
 
