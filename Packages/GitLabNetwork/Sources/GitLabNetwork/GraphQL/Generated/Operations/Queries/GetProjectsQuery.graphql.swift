// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  class GetProjectsQuery: GraphQLQuery {
    static let operationName: String = "GetProjects"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetProjects($first: Int = 20, $after: String, $sort: String) { projects(first: $first, after: $after, visibilityLevel: public, sort: $sort) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } edges { __typename cursor node { __typename id name path fullPath description visibility avatarUrl webUrl starCount forksCount lastActivityAt createdAt updatedAt repository { __typename rootRef empty } namespace { __typename id name path fullPath } } } } }"#
      ))

    public var first: GraphQLNullable<Int>
    public var after: GraphQLNullable<String>
    public var sort: GraphQLNullable<String>

    public init(
      first: GraphQLNullable<Int> = 20,
      after: GraphQLNullable<String>,
      sort: GraphQLNullable<String>
    ) {
      self.first = first
      self.after = after
      self.sort = sort
    }

    public var __variables: Variables? { [
      "first": first,
      "after": after,
      "sort": sort
    ] }

    struct Data: GitLabAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("projects", Projects?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after"),
          "visibilityLevel": "public",
          "sort": .variable("sort")
        ]),
      ] }

      /// Find projects visible to the current user.
      var projects: Projects? { __data["projects"] }

      /// Projects
      ///
      /// Parent Type: `ProjectConnection`
      struct Projects: GitLabAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.ProjectConnection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("edges", [Edge?]?.self),
        ] }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of edges.
        var edges: [Edge?]? { __data["edges"] }

        /// Projects.PageInfo
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

        /// Projects.Edge
        ///
        /// Parent Type: `ProjectEdge`
        struct Edge: GitLabAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.ProjectEdge }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cursor", String.self),
            .field("node", Node?.self),
          ] }

          /// A cursor for use in pagination.
          var cursor: String { __data["cursor"] }
          /// The item at the end of the edge.
          var node: Node? { __data["node"] }

          /// Projects.Edge.Node
          ///
          /// Parent Type: `Project`
          struct Node: GitLabAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", GitLabAPI.ID.self),
              .field("name", String.self),
              .field("path", String.self),
              .field("fullPath", GitLabAPI.ID.self),
              .field("description", String?.self),
              .field("visibility", String?.self),
              .field("avatarUrl", String?.self),
              .field("webUrl", String?.self),
              .field("starCount", Int.self),
              .field("forksCount", Int.self),
              .field("lastActivityAt", GitLabAPI.Time?.self),
              .field("createdAt", GitLabAPI.Time?.self),
              .field("updatedAt", GitLabAPI.Time?.self),
              .field("repository", Repository?.self),
              .field("namespace", Namespace?.self),
            ] }

            /// ID of the project.
            var id: GitLabAPI.ID { __data["id"] }
            /// Name of the project without the namespace.
            var name: String { __data["name"] }
            /// Path of the project.
            var path: String { __data["path"] }
            /// Full path of the project.
            var fullPath: GitLabAPI.ID { __data["fullPath"] }
            /// Short description of the project.
            var description: String? { __data["description"] }
            /// Visibility of the project.
            var visibility: String? { __data["visibility"] }
            /// Avatar URL of the project.
            var avatarUrl: String? { __data["avatarUrl"] }
            /// Web URL of the project.
            var webUrl: String? { __data["webUrl"] }
            /// Number of times the project has been starred.
            var starCount: Int { __data["starCount"] }
            /// Number of times the project has been forked.
            var forksCount: Int { __data["forksCount"] }
            /// Timestamp of the project last activity.
            var lastActivityAt: GitLabAPI.Time? { __data["lastActivityAt"] }
            /// Timestamp of the project creation.
            var createdAt: GitLabAPI.Time? { __data["createdAt"] }
            /// Timestamp of when the project was last updated.
            var updatedAt: GitLabAPI.Time? { __data["updatedAt"] }
            /// Git repository of the project.
            var repository: Repository? { __data["repository"] }
            /// Namespace of the project.
            var namespace: Namespace? { __data["namespace"] }

            /// Projects.Edge.Node.Repository
            ///
            /// Parent Type: `Repository`
            struct Repository: GitLabAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Repository }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("rootRef", String?.self),
                .field("empty", Bool.self),
              ] }

              /// Default branch of the repository.
              var rootRef: String? { __data["rootRef"] }
              /// Indicates repository has no visible content.
              var empty: Bool { __data["empty"] }
            }

            /// Projects.Edge.Node.Namespace
            ///
            /// Parent Type: `Namespace`
            struct Namespace: GitLabAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Namespace }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", GitLabAPI.ID.self),
                .field("name", String.self),
                .field("path", String.self),
                .field("fullPath", GitLabAPI.ID.self),
              ] }

              /// ID of the namespace.
              var id: GitLabAPI.ID { __data["id"] }
              /// Name of the namespace.
              var name: String { __data["name"] }
              /// Path of the namespace.
              var path: String { __data["path"] }
              /// Full path of the namespace.
              var fullPath: GitLabAPI.ID { __data["fullPath"] }
            }
          }
        }
      }
    }
  }

}