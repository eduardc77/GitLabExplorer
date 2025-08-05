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
            // Project avatar or placeholder
            if let avatarURL = project.avatarURL {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.gradient)
                        .overlay {
                            Image(systemName: "folder")
                                .foregroundColor(.white)
                        }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.gradient)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "folder")
                            .foregroundColor(.white)
                    }
            }
            
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
                
                HStack(spacing: 8) {
                    if project.starCount > 0 {
                        Label("\(project.starCount)", systemImage: "star")
                    }
                    if project.forkCount > 0 {
                        Label("\(project.forkCount)", systemImage: "arrow.branch")
                    }
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
