// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  class SearchUsersQuery: GraphQLQuery {
    static let operationName: String = "SearchUsers"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SearchUsers($query: String!, $first: Int = 20, $after: String) { users(search: $query, first: $first, after: $after) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } edges { __typename cursor node { __typename ...UserDetails } } } }"#,
        fragments: [UserBasicInfo.self, UserDetails.self]
      ))

    public var query: String
    public var first: GraphQLNullable<Int>
    public var after: GraphQLNullable<String>

    public init(
      query: String,
      first: GraphQLNullable<Int> = 20,
      after: GraphQLNullable<String>
    ) {
      self.query = query
      self.first = first
      self.after = after
    }

    public var __variables: Variables? { [
      "query": query,
      "first": first,
      "after": after
    ] }

    struct Data: GitLabAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("users", Users?.self, arguments: [
          "search": .variable("query"),
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// Find users.
      var users: Users? { __data["users"] }

      /// Users
      ///
      /// Parent Type: `UserCoreConnection`
      struct Users: GitLabAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCoreConnection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge?]?.self),
        ] }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of edges.
        var edges: [Edge?]? { __data["edges"] }

        /// Users.PageInfo
        ///
        /// Parent Type: `PageInfo`
        struct PageInfo: GitLabAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.PageInfo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("hasPreviousPage", Bool.self),
            .field("startCursor", String?.self),
            .field("endCursor", String?.self),
          ] }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating backwards, are there more items?
          var hasPreviousPage: Bool { __data["hasPreviousPage"] }
          /// When paginating backwards, the cursor to continue.
          var startCursor: String? { __data["startCursor"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }

        /// Users.Edge
        ///
        /// Parent Type: `UserCoreEdge`
        struct Edge: GitLabAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCoreEdge }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node?.self),
          ] }

          /// A cursor for use in pagination.
          var cursor: String { __data["cursor"] }
          /// The item at the end of the edge.
          var node: Node? { __data["node"] }

          /// Users.Edge.Node
          ///
          /// Parent Type: `UserCore`
          struct Node: GitLabAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(UserDetails.self),
            ] }

            /// Bio of the user.
            var bio: String? { __data["bio"] }
            /// Location of the user.
            var location: String? { __data["location"] }
            /// User's public email.
            var publicEmail: String? { __data["publicEmail"] }
            /// Who the user represents or works for.
            var organization: String? { __data["organization"] }
            /// Job title of the user.
            var jobTitle: String? { __data["jobTitle"] }
            /// Pronouns of the user.
            var pronouns: String? { __data["pronouns"] }
            /// Timestamp of when the user was created.
            var createdAt: GitLabAPI.Time? { __data["createdAt"] }
            /// User status.
            var status: Status? { __data["status"] }
            /// Global ID of the user.
            var id: GitLabAPI.UserID { __data["id"] }
            /// Username of the user. Unique within the instance of GitLab.
            var username: String { __data["username"] }
            /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
            var name: String { __data["name"] }
            /// URL of the user's avatar.
            var avatarUrl: String? { __data["avatarUrl"] }
            /// Web URL of the user.
            var webUrl: String { __data["webUrl"] }
            /// State of the user.
            var state: GraphQLEnum<GitLabAPI.UserState> { __data["state"] }
            /// Indicates if the user is a bot.
            var bot: Bool { __data["bot"] }

            struct Fragments: FragmentContainer {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              var userDetails: UserDetails { _toFragment() }
              var userBasicInfo: UserBasicInfo { _toFragment() }
            }

            typealias Status = UserDetails.Status
          }
        }
      }
    }
  }

}