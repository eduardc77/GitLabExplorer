// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  class GetTodosQuery: GraphQLQuery {
    static let operationName: String = "GetTodos"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetTodos($first: Int = 20, $after: String, $state: [TodoStateEnum!]) { currentUser { __typename todos(first: $first, after: $after, state: $state) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } edges { __typename cursor node { __typename id body state createdAt action targetType targetEntity { __typename ... on Issue { id title issueWebUrl: webUrl issueAuthor: author { __typename id name username avatarUrl } } ... on MergeRequest { id title mergeRequestWebUrl: webUrl mergeRequestAuthor: author { __typename id name username avatarUrl } } } project { __typename id name fullPath avatarUrl } author { __typename id name username avatarUrl } } } } } }"#
      ))

    public var first: GraphQLNullable<Int>
    public var after: GraphQLNullable<String>
    public var state: GraphQLNullable<[GraphQLEnum<TodoStateEnum>]>

    public init(
      first: GraphQLNullable<Int> = 20,
      after: GraphQLNullable<String>,
      state: GraphQLNullable<[GraphQLEnum<TodoStateEnum>]>
    ) {
      self.first = first
      self.after = after
      self.state = state
    }

    public var __variables: Variables? { [
      "first": first,
      "after": after,
      "state": state
    ] }

    struct Data: GitLabAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("currentUser", CurrentUser?.self),
      ] }

      /// Get information about current user.
      var currentUser: CurrentUser? { __data["currentUser"] }

      /// CurrentUser
      ///
      /// Parent Type: `CurrentUser`
      struct CurrentUser: GitLabAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.CurrentUser }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("todos", Todos?.self, arguments: [
            "first": .variable("first"),
            "after": .variable("after"),
            "state": .variable("state")
          ]),
        ] }

        /// To-do items of the user.
        var todos: Todos? { __data["todos"] }

        /// CurrentUser.Todos
        ///
        /// Parent Type: `TodoConnection`
        struct Todos: GitLabAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TodoConnection }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("pageInfo", PageInfo.self),
            .field("edges", [Edge?]?.self),
          ] }

          /// Information to aid in pagination.
          var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of edges.
          var edges: [Edge?]? { __data["edges"] }

          /// CurrentUser.Todos.PageInfo
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

          /// CurrentUser.Todos.Edge
          ///
          /// Parent Type: `TodoEdge`
          struct Edge: GitLabAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TodoEdge }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("cursor", String.self),
              .field("node", Node?.self),
            ] }

            /// A cursor for use in pagination.
            var cursor: String { __data["cursor"] }
            /// The item at the end of the edge.
            var node: Node? { __data["node"] }

            /// CurrentUser.Todos.Edge.Node
            ///
            /// Parent Type: `Todo`
            struct Node: GitLabAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Todo }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", GitLabAPI.ID.self),
                .field("body", String.self),
                .field("state", GraphQLEnum<GitLabAPI.TodoStateEnum>.self),
                .field("createdAt", GitLabAPI.Time.self),
                .field("action", GraphQLEnum<GitLabAPI.TodoActionEnum>.self),
                .field("targetType", GraphQLEnum<GitLabAPI.TodoTargetEnum>.self),
                .field("targetEntity", TargetEntity?.self),
                .field("project", Project?.self),
                .field("author", Author.self),
              ] }

              /// ID of the to-do item.
              var id: GitLabAPI.ID { __data["id"] }
              /// Body of the to-do item.
              var body: String { __data["body"] }
              /// State of the to-do item.
              var state: GraphQLEnum<GitLabAPI.TodoStateEnum> { __data["state"] }
              /// Timestamp the to-do item was created.
              var createdAt: GitLabAPI.Time { __data["createdAt"] }
              /// Action of the to-do item.
              var action: GraphQLEnum<GitLabAPI.TodoActionEnum> { __data["action"] }
              /// Target type of the to-do item.
              var targetType: GraphQLEnum<GitLabAPI.TodoTargetEnum> { __data["targetType"] }
              /// Target of the to-do item.
              var targetEntity: TargetEntity? { __data["targetEntity"] }
              /// Project the to-do item is associated with.
              var project: Project? { __data["project"] }
              /// Author of the to-do item.
              var author: Author { __data["author"] }

              /// CurrentUser.Todos.Edge.Node.TargetEntity
              ///
              /// Parent Type: `Todoable`
              struct TargetEntity: GitLabAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.Todoable }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .inlineFragment(AsIssue.self),
                  .inlineFragment(AsMergeRequest.self),
                ] }

                var asIssue: AsIssue? { _asInlineFragment() }
                var asMergeRequest: AsMergeRequest? { _asInlineFragment() }

                /// CurrentUser.Todos.Edge.Node.TargetEntity.AsIssue
                ///
                /// Parent Type: `Issue`
                struct AsIssue: GitLabAPI.InlineFragment {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  typealias RootEntityType = GetTodosQuery.Data.CurrentUser.Todos.Edge.Node.TargetEntity
                  static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Issue }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("id", GitLabAPI.ID.self),
                    .field("title", String.self),
                    .field("webUrl", alias: "issueWebUrl", String.self),
                    .field("author", alias: "issueAuthor", IssueAuthor.self),
                  ] }

                  /// ID of the issue.
                  var id: GitLabAPI.ID { __data["id"] }
                  /// Title of the issue.
                  var title: String { __data["title"] }
                  /// Web URL of the issue.
                  var issueWebUrl: String { __data["issueWebUrl"] }
                  /// User that created the issue.
                  var issueAuthor: IssueAuthor { __data["issueAuthor"] }

                  /// CurrentUser.Todos.Edge.Node.TargetEntity.AsIssue.IssueAuthor
                  ///
                  /// Parent Type: `UserCore`
                  struct IssueAuthor: GitLabAPI.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("id", GitLabAPI.UserID.self),
                      .field("name", String.self),
                      .field("username", String.self),
                      .field("avatarUrl", String?.self),
                    ] }

                    /// Global ID of the user.
                    var id: GitLabAPI.UserID { __data["id"] }
                    /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
                    var name: String { __data["name"] }
                    /// Username of the user. Unique within the instance of GitLab.
                    var username: String { __data["username"] }
                    /// URL of the user's avatar.
                    var avatarUrl: String? { __data["avatarUrl"] }
                  }
                }

                /// CurrentUser.Todos.Edge.Node.TargetEntity.AsMergeRequest
                ///
                /// Parent Type: `MergeRequest`
                struct AsMergeRequest: GitLabAPI.InlineFragment {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  typealias RootEntityType = GetTodosQuery.Data.CurrentUser.Todos.Edge.Node.TargetEntity
                  static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequest }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("id", GitLabAPI.ID.self),
                    .field("title", String.self),
                    .field("webUrl", alias: "mergeRequestWebUrl", String?.self),
                    .field("author", alias: "mergeRequestAuthor", MergeRequestAuthor?.self),
                  ] }

                  /// ID of the merge request.
                  var id: GitLabAPI.ID { __data["id"] }
                  /// Title of the merge request.
                  var title: String { __data["title"] }
                  /// Web URL of the merge request.
                  var mergeRequestWebUrl: String? { __data["mergeRequestWebUrl"] }
                  /// User who created the merge request.
                  var mergeRequestAuthor: MergeRequestAuthor? { __data["mergeRequestAuthor"] }

                  /// CurrentUser.Todos.Edge.Node.TargetEntity.AsMergeRequest.MergeRequestAuthor
                  ///
                  /// Parent Type: `MergeRequestAuthor`
                  struct MergeRequestAuthor: GitLabAPI.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.MergeRequestAuthor }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("id", GitLabAPI.UserID.self),
                      .field("name", String.self),
                      .field("username", String.self),
                      .field("avatarUrl", String?.self),
                    ] }

                    /// Global ID of the user.
                    var id: GitLabAPI.UserID { __data["id"] }
                    /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
                    var name: String { __data["name"] }
                    /// Username of the user. Unique within the instance of GitLab.
                    var username: String { __data["username"] }
                    /// URL of the user's avatar.
                    var avatarUrl: String? { __data["avatarUrl"] }
                  }
                }
              }

              /// CurrentUser.Todos.Edge.Node.Project
              ///
              /// Parent Type: `Project`
              struct Project: GitLabAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Project }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("id", GitLabAPI.ID.self),
                  .field("name", String.self),
                  .field("fullPath", GitLabAPI.ID.self),
                  .field("avatarUrl", String?.self),
                ] }

                /// ID of the project.
                var id: GitLabAPI.ID { __data["id"] }
                /// Name of the project without the namespace.
                var name: String { __data["name"] }
                /// Full path of the project.
                var fullPath: GitLabAPI.ID { __data["fullPath"] }
                /// Avatar URL of the project.
                var avatarUrl: String? { __data["avatarUrl"] }
              }

              /// CurrentUser.Todos.Edge.Node.Author
              ///
              /// Parent Type: `UserCore`
              struct Author: GitLabAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserCore }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("id", GitLabAPI.UserID.self),
                  .field("name", String.self),
                  .field("username", String.self),
                  .field("avatarUrl", String?.self),
                ] }

                /// Global ID of the user.
                var id: GitLabAPI.UserID { __data["id"] }
                /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
                var name: String { __data["name"] }
                /// Username of the user. Unique within the instance of GitLab.
                var username: String { __data["username"] }
                /// URL of the user's avatar.
                var avatarUrl: String? { __data["avatarUrl"] }
              }
            }
          }
        }
      }
    }
  }

}