// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  struct UserBasicInfo: GitLabAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment UserBasicInfo on User { __typename id username name avatarUrl webUrl state bot }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.User }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GitLabAPI.UserID.self),
      .field("username", String.self),
      .field("name", String.self),
      .field("avatarUrl", String?.self),
      .field("webUrl", String.self),
      .field("state", GraphQLEnum<GitLabAPI.UserState>.self),
      .field("bot", Bool.self),
    ] }

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
  }

}