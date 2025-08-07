//
//  ProjectRowView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct ProjectRowView: View {
    let project: ProjectSummary
    
    var body: some View {
        HStack {
            ProjectImageView(
                imageURL: project.avatarURL,
                aspectRatio: 1,
                cornerRadius: 8
            )
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .lineLimit(1)

                if let description = project.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Label("\(project.starCount)", systemImage: "star")
                        .tightSpacing()
                        .lineLimit(1)
                    Label("\(project.forkCount)", systemImage: "arrow.branch")
                        .tightSpacing()
                        .lineLimit(1)
                    Spacer()
                    Text("Updated \(project.updatedAt, format: .relative(presentation: .named))")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleProject = ProjectSummary(
        id: "1",
        name: "Sample Project",
        nameWithOwner: "user/sample-project",
        description: "A sample project for testing the UI",
        starCount: 42,
        forkCount: 12,
        language: "Swift",
        owner: ProjectOwner(
            login: "user",
            name: "Sample User",
            avatarURL: nil,
            type: .user,
            webURL: URL(string: "https://gitlab.com/user")
        ),
        updatedAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
        avatarURL: nil,
        webURL: URL(string: "https://gitlab.com/user/sample-project")!
    )
    
    ProjectRowView(project: sampleProject)
        .padding()
}
