// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI.Objects {
  /// Represents an epic
  static let Epic = ApolloAPI.Object(
    typename: "Epic",
    implementedInterfaces: [
      GitLabAPI.Interfaces.CurrentUserTodos.self,
      GitLabAPI.Interfaces.Eventable.self,
      GitLabAPI.Interfaces.NoteableInterface.self,
      GitLabAPI.Interfaces.Todoable.self
    ],
    keyFields: nil
  )
}