//
//  SettingsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        NavigationStack {
            Form {
                // Account Settings Section
                Section {
                    SettingsRow(
                        icon: "bell",
                        title: "Notifications",
                        subtitle: "Manage your notification preferences"
                    ) {
                        // TODO: Navigate to notifications settings
                    }
                    
                    SettingsRow(
                        icon: "lock",
                        title: "Privacy",
                        subtitle: "Control your privacy settings"
                    ) {
                        // TODO: Navigate to privacy settings
                    }
                    
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        subtitle: "Get help and contact support"
                    ) {
                        // TODO: Navigate to help
                    }
                } header: {
                    Text("Settings")
                }
                
                // Account Management Section
                if authStore.isAuthenticated {
                    Section {
                        SignOutSection()
                    } header: {
                        Text("Account")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthenticationStore())
} 
