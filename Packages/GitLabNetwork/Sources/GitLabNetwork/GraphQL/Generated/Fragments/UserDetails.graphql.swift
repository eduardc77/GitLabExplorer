// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  struct UserDetails: GitLabAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment UserDetails on User { __typename ...UserBasicInfo bio location publicEmail organization jobTitle pronouns createdAt status { __typename emoji message availability } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Interfaces.User }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("bio", String?.self),
      .field("location", String?.self),
      .field("publicEmail", String?.self),
      .field("organization", String?.self),
      .field("jobTitle", String?.self),
      .field("pronouns", String?.self),
      .field("createdAt", GitLabAPI.Time?.self),
      .field("status", Status?.self),
      .fragment(UserBasicInfo.self),
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

      var userBasicInfo: UserBasicInfo { _toFragment() }
    }

    /// Status
    ///
    /// Parent Type: `UserStatus`
    struct Status: GitLabAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.UserStatus }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("emoji", String?.self),
        .field("message", String?.self),
        .field("availability", GraphQLEnum<GitLabAPI.AvailabilityEnum>.self),
      ] }

      /// String representation of emoji.
      var emoji: String? { __data["emoji"] }
      /// User status message.
      var message: String? { __data["message"] }
      /// User availability status.
      var availability: GraphQLEnum<GitLabAPI.AvailabilityEnum> { __data["availability"] }
    }
  }

}