// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GitLabAPI {
  class TodoMarkDoneMutation: GraphQLMutation {
    static let operationName: String = "TodoMarkDone"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation TodoMarkDone($id: TodoID!) { todoMarkDone(input: { id: $id }) { __typename errors todo { __typename id state } } }"#
      ))

    public var id: TodoID

    public init(id: TodoID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: GitLabAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("todoMarkDone", TodoMarkDone?.self, arguments: ["input": ["id": .variable("id")]]),
      ] }

      var todoMarkDone: TodoMarkDone? { __data["todoMarkDone"] }

      /// TodoMarkDone
      ///
      /// Parent Type: `TodoMarkDonePayload`
      struct TodoMarkDone: GitLabAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.TodoMarkDonePayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("errors", [String].self),
          .field("todo", Todo.self),
        ] }

        /// Errors encountered during the mutation.
        var errors: [String] { __data["errors"] }
        /// Requested to-do item.
        var todo: Todo { __data["todo"] }

        /// TodoMarkDone.Todo
        ///
        /// Parent Type: `Todo`
        struct Todo: GitLabAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GitLabAPI.Objects.Todo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GitLabAPI.ID.self),
            .field("state", GraphQLEnum<GitLabAPI.TodoStateEnum>.self),
          ] }

          /// ID of the to-do item.
          var id: GitLabAPI.ID { __data["id"] }
          /// State of the to-do item.
          var state: GraphQLEnum<GitLabAPI.TodoStateEnum> { __data["state"] }
        }
      }
    }
  }

}