//
//  YourWorkSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct YourWorkSection: View {
    @Environment(ServiceFactory.self) private var serviceFactory
    
    var body: some View {
        Section {
            WorkItemRow(
                icon: "folder.fill",
                title: "Personal Projects",
                subtitle: "Projects you own or maintain",
                iconColor: .blue,
                destination: .personalProjects
            )

            WorkItemRow(
                icon: "person.2.fill",
                title: "Groups",
                subtitle: "Groups you are a member of",
                iconColor: .green,
                destination: .groups
            )

            WorkItemRow(
                icon: "exclamationmark.circle.fill",
                title: "Assigned Issues",
                subtitle: "Issues assigned to you or created by you",
                iconColor: .orange,
                destination: .assignedIssues
            )

            WorkItemRow(
                icon: "arrow.triangle.merge",
                title: "Merge Requests",
                subtitle: "Merge requests you created or need to review",
                iconColor: .purple,
                destination: .mergeRequests
            )
        } header: {
            Text("Your Work")
        }
    }
}

// MARK: - Supporting Views

struct WorkItemRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let destination: AccountCoordinator.Destination

    var body: some View {
        NavigationLink(value: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    YourWorkSection()
        .padding()
        .environment(ServiceFactory(configuration: GitLabConfiguration.fromInfoPlist(), authProvider: GitLabAuthProvider(tokenManager: TokenManager(configuration: GitLabConfiguration.fromInfoPlist()))))
}
