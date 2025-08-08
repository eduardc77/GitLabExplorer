//
//  UserProfileSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct UserProfileSection: View {
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                AvatarView(
                    imageURL: authStore.currentUser?.avatarUrl,
                    size: 80,
                    placeholder: "👤"
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    if let user = authStore.currentUser {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let email = user.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let createdAt = user.createdAt {
                            Text("Member since \(createdAt.formatted(.dateTime.month().day().year()))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    } else if authStore.isLoadingUser {
                        VStack(alignment: .leading, spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Loading profile...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Bio section
            if let bio = authStore.currentUser?.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } 
            }
        }
    }
}

#Preview {
    UserProfileSection()
        .environment(AuthenticationStore())
        .padding()
} 
