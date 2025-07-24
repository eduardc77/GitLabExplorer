//
//  AccountSettingsSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
            
            VStack(spacing: 12) {
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AccountSettingsSection()
        .padding()
} 
