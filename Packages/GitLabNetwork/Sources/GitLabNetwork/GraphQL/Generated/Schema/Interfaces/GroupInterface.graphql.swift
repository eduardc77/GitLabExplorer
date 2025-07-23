// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI.Interfaces {
  /// Returns either a "Group" type for users with :read_group permission, or a "GroupMinimalAccess" type for users with only :read_group_metadata permission.
  static let GroupInterface = ApolloAPI.Interface(
    name: "GroupInterface",
    keyFields: nil,
    implementingObjects: [
      "Group",
      "GroupMinimalAccess"
    ]
  )
}