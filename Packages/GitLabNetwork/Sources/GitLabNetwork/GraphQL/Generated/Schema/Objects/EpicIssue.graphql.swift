// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI.Objects {
  /// Relationship between an epic and an issue
  static let EpicIssue = ApolloAPI.Object(
    typename: "EpicIssue",
    implementedInterfaces: [
      GitLabAPI.Interfaces.CurrentUserTodos.self,
      GitLabAPI.Interfaces.NoteableInterface.self,
      GitLabAPI.Interfaces.Todoable.self
    ],
    keyFields: nil
  )
}