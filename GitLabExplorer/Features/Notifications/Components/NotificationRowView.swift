import SwiftUI
import GitLabNetwork

struct NotificationRowView: View {
    let notification: GitLabNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Notification Icon
            notificationIcon
                .foregroundColor(notification.isUnread ? .blue : .secondary)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title & Action
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(notification.displayTitle)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        actionText
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Unread indicator
                    if notification.isUnread {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Project & Time
                HStack {
                    if let project = notification.project {
                        Label(project.name, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(notification.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .background(notification.isUnread ? Color.blue.opacity(0.05) : Color.clear)
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var notificationIcon: some View {
        Group {
            switch notification.action {
            case .assigned:
                Image(systemName: "person.badge.plus")
            case .mentioned:
                Image(systemName: "at")
            case .buildFailed:
                Image(systemName: "xmark.circle")
            case .marked:
                Image(systemName: "checkmark.circle")
            case .approvalRequired:
                Image(systemName: "hand.raised")
            case .unmergeable:
                Image(systemName: "arrow.triangle.merge")
            case .directlyAddressed:
                Image(systemName: "envelope")
            case .mergeTrainRemoved:
                Image(systemName: "train.side.rear.car")
            }
        }
        .font(.title2)
    }
    
    private var actionText: Text {
        let actionDescription: String
        let authorName = notification.author?.name ?? "Someone"
        
        switch notification.action {
        case .assigned:
            actionDescription = "\(authorName) assigned you"
        case .mentioned:
            actionDescription = "\(authorName) mentioned you"
        case .buildFailed:
            actionDescription = "Build failed"
        case .marked:
            actionDescription = "\(authorName) marked this"
        case .approvalRequired:
            actionDescription = "Approval required"
        case .unmergeable:
            actionDescription = "Cannot be merged"
        case .directlyAddressed:
            actionDescription = "\(authorName) addressed you"
        case .mergeTrainRemoved:
            actionDescription = "Removed from merge train"
        }
        
        return Text(actionDescription)
    }
}

// MARK: - Preview

#Preview("Unread Assignment") {
    List {
        NotificationRowView(
            notification: GitLabNotification(
                id: "1",
                body: "You have been assigned to this issue",
                state: .pending,
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                updatedAt: nil,
                action: .assigned,
                targetType: "Issue",
                target: TodoTarget(
                    id: "123",
                    title: "Fix authentication bug in login flow",
                    webUrl: "https://gitlab.com/project/issues/123",
                    author: nil
                ),
                project: TodoProject(
                    id: "proj1",
                    name: "GitLab Explorer",
                    fullPath: "eduardc77/gitlab-explorer",
                    webUrl: "https://gitlab.com/eduardc77/gitlab-explorer"
                ),
                author: GitLabUser(
                    id: "author1",
                    username: "johndoe",
                    name: "John Doe",
                    email: "john@example.com",
                    avatarUrl: nil,
                    bio: nil,
                    location: nil,
                    webUrl: nil,
                    createdAt: nil,
                    lastActivityOn: nil,
                    state: .active
                )
            )
        )
        
        NotificationRowView(
            notification: GitLabNotification(
                id: "2",
                body: "You were mentioned in this merge request",
                state: .done,
                createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                updatedAt: nil,
                action: .mentioned,
                targetType: "MergeRequest",
                target: TodoTarget(
                    id: "456",
                    title: "Add dark mode support",
                    webUrl: "https://gitlab.com/project/merge_requests/456",
                    author: nil
                ),
                project: TodoProject(
                    id: "proj1",
                    name: "Mobile App",
                    fullPath: "company/mobile-app",
                    webUrl: "https://gitlab.com/company/mobile-app"
                ),
                author: GitLabUser(
                    id: "author2",
                    username: "jane",
                    name: "Jane Smith",
                    email: "jane@example.com",
                    avatarUrl: nil,
                    bio: nil,
                    location: nil,
                    webUrl: nil,
                    createdAt: nil,
                    lastActivityOn: nil,
                    state: .active
                )
            )
        )
    }
}

#Preview("Build Failed") {
    NotificationRowView(
        notification: GitLabNotification(
            id: "3",
            body: "Pipeline failed for main branch",
            state: .pending,
            createdAt: Date().addingTimeInterval(-1800), // 30 minutes ago
            updatedAt: nil,
            action: .buildFailed,
            targetType: "Pipeline",
            target: nil,
            project: TodoProject(
                id: "proj2",
                name: "Backend API",
                fullPath: "company/backend-api",
                webUrl: "https://gitlab.com/company/backend-api"
            ),
            author: nil
        )
    )
    .padding()
} 