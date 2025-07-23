// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  class CurrentUserQuery: GraphQLQuery {
    static let operationName: String = "CurrentUser"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CurrentUser { currentUser { __typename id username name email avatarUrl bio location webUrl publicEmail createdAt lastActivityOn state } }"#
      ))

    public init() {}

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
          .field("id", GitLabAPI.UserID.self),
          .field("username", String.self),
          .field("name", String.self),
          .field("email", String?.self),
          .field("avatarUrl", String?.self),
          .field("bio", String?.self),
          .field("location", String?.self),
          .field("webUrl", String.self),
          .field("publicEmail", String?.self),
          .field("createdAt", GitLabAPI.Time?.self),
          .field("lastActivityOn", GitLabAPI.Date?.self),
          .field("state", GraphQLEnum<GitLabAPI.UserState>.self),
        ] }

        /// Global ID of the user.
        var id: GitLabAPI.UserID { __data["id"] }
        /// Username of the user. Unique within the instance of GitLab.
        var username: String { __data["username"] }
        /// Human-readable name of the user. Returns `****` if the user is a project bot and the requester does not have permission to view the project.
        var name: String { __data["name"] }
        /// User email. Deprecated in GitLab 13.7: This was renamed.
        @available(*, deprecated, message: "This was renamed. Please use `User.publicEmail`. Deprecated in GitLab 13.7.")
        var email: String? { __data["email"] }
        /// URL of the user's avatar.
        var avatarUrl: String? { __data["avatarUrl"] }
        /// Bio of the user.
        var bio: String? { __data["bio"] }
        /// Location of the user.
        var location: String? { __data["location"] }
        /// Web URL of the user.
        var webUrl: String { __data["webUrl"] }
        /// User's public email.
        var publicEmail: String? { __data["publicEmail"] }
        /// Timestamp of when the user was created.
        var createdAt: GitLabAPI.Time? { __data["createdAt"] }
        /// Date the user last performed any actions.
        var lastActivityOn: GitLabAPI.Date? { __data["lastActivityOn"] }
        /// State of the user.
        var state: GraphQLEnum<GitLabAPI.UserState> { __data["state"] }
      }
    }
  }

}