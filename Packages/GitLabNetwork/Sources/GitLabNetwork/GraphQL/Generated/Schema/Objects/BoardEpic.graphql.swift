// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI.Objects {
  /// Represents an epic on an issue board
  static let BoardEpic = ApolloAPI.Object(
    typename: "BoardEpic",
    implementedInterfaces: [
      GitLabAPI.Interfaces.CurrentUserTodos.self,
      GitLabAPI.Interfaces.Eventable.self,
      GitLabAPI.Interfaces.NoteableInterface.self,
      GitLabAPI.Interfaces.Todoable.self
    ],
    keyFields: nil
  )
}