// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension GitLabAPI {
  /// Possible states of a user
  enum UserState: String, EnumType {
    /// User is active and can use the system.
    case active = "active"
    /// User has been blocked by an administrator and cannot use the system.
    case blocked = "blocked"
    /// User is no longer active and cannot use the system.
    case deactivated = "deactivated"
    /// User is blocked, and their contributions are hidden.
    case banned = "banned"
    /// User has been blocked by the system.
    case ldapBlocked = "ldap_blocked"
    /// User is blocked and pending approval.
    case blockedPendingApproval = "blocked_pending_approval"
  }

}