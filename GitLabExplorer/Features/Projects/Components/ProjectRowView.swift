//
//  ProjectRowView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        HStack(spacing: 12) {
            // Project Avatar
            ProjectAvatarView(project: project)
            
            // Project Info
            VStack(alignment: .leading, spacing: 4) {
                // Project Name and Namespace
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(project.nameWithNamespace)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Description
                if let description = project.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Project Metadata
                HStack(spacing: 12) {
                    // Visibility
                    HStack(spacing: 4) {
                        Image(systemName: project.visibility.iconName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(project.visibility.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stars
                    if project.starCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            
                            Text("\(project.starCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Forks
                    if project.forksCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(project.forksCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Open Issues
                    if project.openIssuesCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(project.openIssuesCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Last Activity
                    Text(RelativeDateTimeFormatter().localizedString(for: project.lastActivityAt, relativeTo: Date()))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Topics
                if !project.topics.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(project.topics.prefix(3), id: \.self) { topic in
                                Text(topic)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                            
                            if project.topics.count > 3 {
                                Text("+\(project.topics.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct ProjectAvatarView: View {
    let project: Project
    
    var body: some View {
        Group {
            if let avatarUrl = project.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProjectPlaceholderView(project: project)
                }
            } else {
                ProjectPlaceholderView(project: project)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

struct ProjectPlaceholderView: View {
    let project: Project
    
    private var backgroundColor: Color {
        // Generate a consistent color based on project ID
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .indigo, .teal, .cyan]
        return colors[project.id % colors.count]
    }
    
    private var initials: String {
        let components = project.name.components(separatedBy: .whitespacesAndNewlines)
        let initials = components.compactMap { $0.first?.uppercased() }.prefix(2).joined()
        return initials.isEmpty ? "P" : initials
    }
    
    var body: some View {
        ZStack {
            backgroundColor.gradient
            
            Text(initials)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

#Preview("Single Project") {
    List {
        ProjectRowView(project: Project(
            id: 1,
            name: "GitLabExplorer",
            nameWithNamespace: "user / GitLabExplorer",
            path: "gitlabexplorer",
            pathWithNamespace: "user/gitlabexplorer",
            description: "A beautiful GitLab client for iOS built with SwiftUI and modern architecture patterns",
            defaultBranch: "main",
            visibility: .public,
            webUrl: "https://gitlab.com/user/gitlabexplorer",
            httpUrlToRepo: "https://gitlab.com/user/gitlabexplorer.git",
            sshUrlToRepo: "git@gitlab.com:user/gitlabexplorer.git",
            avatarUrl: nil,
            starCount: 15,
            forksCount: 3,
            lastActivityAt: Date().addingTimeInterval(-3600),
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: Date().addingTimeInterval(-1800),
            archived: false,
            issuesEnabled: true,
            mergeRequestsEnabled: true,
            wikiEnabled: true,
            jobsEnabled: true,
            snippetsEnabled: true,
            containerRegistryEnabled: true,
            openIssuesCount: 5,
            topics: ["ios", "swift", "gitlab", "swiftui"],
            namespace: ProjectNamespace(
                id: 1,
                name: "user",
                path: "user",
                kind: "user",
                fullPath: "user",
                avatarUrl: nil,
                webUrl: "https://gitlab.com/user"
            ),
            owner: ProjectOwner(
                id: 1,
                name: "User",
                createdAt: Date().addingTimeInterval(-86400 * 365)
            ),
            permissions: nil,
            statistics: ProjectStatistics(
                commitCount: 127,
                storageSize: 1024000,
                repositorySize: 512000,
                wikiSize: 0,
                lfsObjectsSize: 0,
                jobArtifactsSize: 256000,
                packagesSize: 0,
                snippetsSize: 0,
                uploadsSize: 256000,
                containerRegistrySize: 0
            )
        ))
        
        ProjectRowView(project: Project(
            id: 2,
            name: "iOS Utils",
            nameWithNamespace: "company / iOS Utils",
            path: "ios-utils",
            pathWithNamespace: "company/ios-utils",
            description: nil,
            defaultBranch: "main",
            visibility: .private,
            webUrl: "https://gitlab.com/company/ios-utils",
            httpUrlToRepo: "https://gitlab.com/company/ios-utils.git",
            sshUrlToRepo: "git@gitlab.com:company/ios-utils.git",
            avatarUrl: nil,
            starCount: 0,
            forksCount: 0,
            lastActivityAt: Date().addingTimeInterval(-86400 * 2),
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date().addingTimeInterval(-86400),
            archived: false,
            issuesEnabled: true,
            mergeRequestsEnabled: true,
            wikiEnabled: false,
            jobsEnabled: true,
            snippetsEnabled: false,
            containerRegistryEnabled: false,
            openIssuesCount: 0,
            topics: [],
            namespace: ProjectNamespace(
                id: 2,
                name: "company",
                path: "company",
                kind: "group",
                fullPath: "company",
                avatarUrl: nil,
                webUrl: "https://gitlab.com/company"
            ),
            owner: nil,
            permissions: nil,
            statistics: nil
        ))
    }
    .listStyle(.plain)
}

#Preview("Multiple Projects") {
    NavigationView {
        List {
            ForEach(0..<5) { index in
                ProjectRowView(project: Project(
                    id: index,
                    name: "Project \(index + 1)",
                    nameWithNamespace: "user / Project \(index + 1)",
                    path: "project-\(index + 1)",
                    pathWithNamespace: "user/project-\(index + 1)",
                    description: index % 2 == 0 ? "This is a sample project description that might be quite long and span multiple lines to test the layout" : nil,
                    defaultBranch: "main",
                    visibility: ProjectVisibility.allCases[index % ProjectVisibility.allCases.count],
                    webUrl: "https://gitlab.com/user/project-\(index + 1)",
                    httpUrlToRepo: "https://gitlab.com/user/project-\(index + 1).git",
                    sshUrlToRepo: "git@gitlab.com:user/project-\(index + 1).git",
                    avatarUrl: nil,
                    starCount: index * 3,
                    forksCount: index,
                    lastActivityAt: Date().addingTimeInterval(TimeInterval(-3600 * index)),
                    createdAt: Date().addingTimeInterval(TimeInterval(-86400 * (30 + index))),
                    updatedAt: Date().addingTimeInterval(TimeInterval(-1800 * index)),
                    archived: false,
                    issuesEnabled: true,
                    mergeRequestsEnabled: true,
                    wikiEnabled: true,
                    jobsEnabled: true,
                    snippetsEnabled: true,
                    containerRegistryEnabled: true,
                    openIssuesCount: index * 2,
                    topics: index % 2 == 0 ? ["ios", "swift"] : ["web", "javascript", "vue", "api", "backend"],
                    namespace: ProjectNamespace(
                        id: 1,
                        name: "user",
                        path: "user",
                        kind: "user",
                        fullPath: "user",
                        avatarUrl: nil,
                        webUrl: "https://gitlab.com/user"
                    ),
                    owner: ProjectOwner(
                        id: 1,
                        name: "User",
                        createdAt: Date().addingTimeInterval(-86400 * 365)
                    ),
                    permissions: nil,
                    statistics: nil
                ))
            }
        }
        .navigationTitle("Projects")
        .listStyle(.plain)
    }
}
