// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol GitLabAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GitLabAPI.SchemaMetadata {}

protocol GitLabAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GitLabAPI.SchemaMetadata {}

protocol GitLabAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GitLabAPI.SchemaMetadata {}

protocol GitLabAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GitLabAPI.SchemaMetadata {}

extension GitLabAPI {
  typealias SelectionSet = GitLabAPI_SelectionSet

  typealias InlineFragment = GitLabAPI_InlineFragment

  typealias MutableSelectionSet = GitLabAPI_MutableSelectionSet

  typealias MutableInlineFragment = GitLabAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "AddOnUser": return GitLabAPI.Objects.AddOnUser
      case "AlertManagementAlert": return GitLabAPI.Objects.AlertManagementAlert
      case "AutocompletedUser": return GitLabAPI.Objects.AutocompletedUser
      case "BoardEpic": return GitLabAPI.Objects.BoardEpic
      case "Commit": return GitLabAPI.Objects.Commit
      case "CountableVulnerability": return GitLabAPI.Objects.CountableVulnerability
      case "CurrentUser": return GitLabAPI.Objects.CurrentUser
      case "Design": return GitLabAPI.Objects.Design
      case "DesignAtVersion": return GitLabAPI.Objects.DesignAtVersion
      case "Epic": return GitLabAPI.Objects.Epic
      case "EpicIssue": return GitLabAPI.Objects.EpicIssue
      case "Group": return GitLabAPI.Objects.Group
      case "GroupMinimalAccess": return GitLabAPI.Objects.GroupMinimalAccess
      case "Issue": return GitLabAPI.Objects.Issue
      case "Key": return GitLabAPI.Objects.Key
      case "MergeRequest": return GitLabAPI.Objects.MergeRequest
      case "MergeRequestAssignee": return GitLabAPI.Objects.MergeRequestAssignee
      case "MergeRequestAuthor": return GitLabAPI.Objects.MergeRequestAuthor
      case "MergeRequestParticipant": return GitLabAPI.Objects.MergeRequestParticipant
      case "MergeRequestReviewer": return GitLabAPI.Objects.MergeRequestReviewer
      case "Mutation": return GitLabAPI.Objects.Mutation
      case "Namespace": return GitLabAPI.Objects.Namespace
      case "PageInfo": return GitLabAPI.Objects.PageInfo
      case "Project": return GitLabAPI.Objects.Project
      case "ProjectComplianceViolation": return GitLabAPI.Objects.ProjectComplianceViolation
      case "ProjectMinimalAccess": return GitLabAPI.Objects.ProjectMinimalAccess
      case "Query": return GitLabAPI.Objects.Query
      case "Snippet": return GitLabAPI.Objects.Snippet
      case "Todo": return GitLabAPI.Objects.Todo
      case "TodoConnection": return GitLabAPI.Objects.TodoConnection
      case "TodoEdge": return GitLabAPI.Objects.TodoEdge
      case "TodoMarkDonePayload": return GitLabAPI.Objects.TodoMarkDonePayload
      case "UserCore": return GitLabAPI.Objects.UserCore
      case "UserCoreConnection": return GitLabAPI.Objects.UserCoreConnection
      case "UserCoreEdge": return GitLabAPI.Objects.UserCoreEdge
      case "UserStatus": return GitLabAPI.Objects.UserStatus
      case "Vulnerability": return GitLabAPI.Objects.Vulnerability
      case "WikiPage": return GitLabAPI.Objects.WikiPage
      case "WorkItem": return GitLabAPI.Objects.WorkItem
      case "WorkItemWidgetAssignees": return GitLabAPI.Objects.WorkItemWidgetAssignees
      case "WorkItemWidgetAwardEmoji": return GitLabAPI.Objects.WorkItemWidgetAwardEmoji
      case "WorkItemWidgetColor": return GitLabAPI.Objects.WorkItemWidgetColor
      case "WorkItemWidgetCrmContacts": return GitLabAPI.Objects.WorkItemWidgetCrmContacts
      case "WorkItemWidgetCurrentUserTodos": return GitLabAPI.Objects.WorkItemWidgetCurrentUserTodos
      case "WorkItemWidgetCustomFields": return GitLabAPI.Objects.WorkItemWidgetCustomFields
      case "WorkItemWidgetDescription": return GitLabAPI.Objects.WorkItemWidgetDescription
      case "WorkItemWidgetDesigns": return GitLabAPI.Objects.WorkItemWidgetDesigns
      case "WorkItemWidgetDevelopment": return GitLabAPI.Objects.WorkItemWidgetDevelopment
      case "WorkItemWidgetEmailParticipants": return GitLabAPI.Objects.WorkItemWidgetEmailParticipants
      case "WorkItemWidgetErrorTracking": return GitLabAPI.Objects.WorkItemWidgetErrorTracking
      case "WorkItemWidgetHealthStatus": return GitLabAPI.Objects.WorkItemWidgetHealthStatus
      case "WorkItemWidgetHierarchy": return GitLabAPI.Objects.WorkItemWidgetHierarchy
      case "WorkItemWidgetIteration": return GitLabAPI.Objects.WorkItemWidgetIteration
      case "WorkItemWidgetLabels": return GitLabAPI.Objects.WorkItemWidgetLabels
      case "WorkItemWidgetLinkedItems": return GitLabAPI.Objects.WorkItemWidgetLinkedItems
      case "WorkItemWidgetLinkedResources": return GitLabAPI.Objects.WorkItemWidgetLinkedResources
      case "WorkItemWidgetMilestone": return GitLabAPI.Objects.WorkItemWidgetMilestone
      case "WorkItemWidgetNotes": return GitLabAPI.Objects.WorkItemWidgetNotes
      case "WorkItemWidgetNotifications": return GitLabAPI.Objects.WorkItemWidgetNotifications
      case "WorkItemWidgetParticipants": return GitLabAPI.Objects.WorkItemWidgetParticipants
      case "WorkItemWidgetProgress": return GitLabAPI.Objects.WorkItemWidgetProgress
      case "WorkItemWidgetRequirementLegacy": return GitLabAPI.Objects.WorkItemWidgetRequirementLegacy
      case "WorkItemWidgetStartAndDueDate": return GitLabAPI.Objects.WorkItemWidgetStartAndDueDate
      case "WorkItemWidgetStatus": return GitLabAPI.Objects.WorkItemWidgetStatus
      case "WorkItemWidgetTestReports": return GitLabAPI.Objects.WorkItemWidgetTestReports
      case "WorkItemWidgetTimeTracking": return GitLabAPI.Objects.WorkItemWidgetTimeTracking
      case "WorkItemWidgetVerificationStatus": return GitLabAPI.Objects.WorkItemWidgetVerificationStatus
      case "WorkItemWidgetVulnerabilities": return GitLabAPI.Objects.WorkItemWidgetVulnerabilities
      case "WorkItemWidgetWeight": return GitLabAPI.Objects.WorkItemWidgetWeight
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}