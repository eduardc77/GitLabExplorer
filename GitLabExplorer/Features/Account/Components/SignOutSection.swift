//
//  SignOutSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct SignOutSection: View {
    @Environment(AuthenticationStore.self) private var authStore
    @State private var showingSignOutAlert = false
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                Button {
                    showingSignOutAlert = true
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authStore.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    SignOutSection()
        .environment(AuthenticationStore())
        .padding()
} 
