//
//  YourWorkSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct YourWorkSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Work")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                WorkItemRow(
                    icon: "folder.fill",
                    title: "My Projects",
                    subtitle: "Projects you own or contribute to",
                    iconColor: .blue
                ) {
                    // TODO: Navigate to my projects
                }
                
                WorkItemRow(
                    icon: "person.2.fill",
                    title: "My Groups",
                    subtitle: "Groups you're a member of",
                    iconColor: .green
                ) {
                    // TODO: Navigate to my groups
                }
                
                WorkItemRow(
                    icon: "exclamationmark.circle.fill",
                    title: "My Issues",
                    subtitle: "Issues assigned to you or created by you",
                    iconColor: .orange
                ) {
                    // TODO: Navigate to my issues
                }
                
                WorkItemRow(
                    icon: "arrow.triangle.merge",
                    title: "My Merge Requests",
                    subtitle: "Merge requests you created or need to review",
                    iconColor: .purple
                ) {
                    // TODO: Navigate to my merge requests
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Supporting Views

struct WorkItemRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    YourWorkSection()
        .padding()
} 
