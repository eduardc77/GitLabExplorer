//
//  AccountHeaderView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("Welcome to GitLab Explorer")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Sign in to access your projects, follow users, and contribute to the GitLab community.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    AccountHeaderView()
        .padding()
}
