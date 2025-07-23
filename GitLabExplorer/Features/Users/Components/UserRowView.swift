//
//  UserRowView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct UserRowView: View {
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(.green.gradient)
                .frame(width: 40, height: 40)
                .overlay {
                    Text("U\(index + 1)")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("User \(index + 1)")
                    .font(.headline)
                Text("@user\(index + 1) • GitLab Developer")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Follow") {
                // TODO: Follow user
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    UserRowView(index: 0)
        .padding()
}
