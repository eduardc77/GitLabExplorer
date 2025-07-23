// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI.Objects {
  /// The currently authenticated GitLab user.
  static let CurrentUser = ApolloAPI.Object(
    typename: "CurrentUser",
    implementedInterfaces: [
      GitLabAPI.Interfaces.Todoable.self,
      GitLabAPI.Interfaces.User.self
    ],
    keyFields: nil
  )
}