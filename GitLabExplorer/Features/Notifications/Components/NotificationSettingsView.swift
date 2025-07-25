//
//  NotificationSettingsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct NotificationSettingsView: View {
    @Environment(NotificationsStore.self) private var notificationsStore
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    
    // Settings state
    @State private var enableNotifications = true
    @State private var enableMentions = true
    @State private var enableAssignments = true
    @State private var enableBuildFailures = true
    @State private var enableApprovalRequests = true
    @State private var enablePushNotifications = true
    @State private var enableEmailNotifications = true
    
    var body: some View {
        NavigationStack {
            List {
                // Main toggle
                Section {
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                } footer: {
                    Text("Receive GitLab notifications in the app and optionally via push notifications.")
                }
                
                // Notification types (only if enabled)
                if enableNotifications {
                    Section("Notification Types") {
                        NotificationTypeRow(
                            icon: "at",
                            title: "Mentions",
                            description: "When someone mentions you",
                            isEnabled: $enableMentions
                        )
                        
                        NotificationTypeRow(
                            icon: "person.badge.plus",
                            title: "Assignments",
                            description: "When you're assigned to issues or merge requests",
                            isEnabled: $enableAssignments
                        )
                        
                        NotificationTypeRow(
                            icon: "xmark.circle",
                            title: "Build Failures",
                            description: "When pipelines fail",
                            isEnabled: $enableBuildFailures
                        )
                        
                        NotificationTypeRow(
                            icon: "hand.raised",
                            title: "Approval Requests",
                            description: "When your approval is requested",
                            isEnabled: $enableApprovalRequests
                        )
                    }
                    
                    // Delivery methods
                    Section {
                        Toggle("Push Notifications", isOn: $enablePushNotifications)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Toggle("Email Notifications", isOn: $enableEmailNotifications)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    } header: {
                        Text("Delivery")
                    } footer: {
                        Text("Choose how you want to receive notifications. Push notifications require permission.")
                    }
                    
                    // Actions
                    Section {
                        Button("Mark All as Read") {
                            Task {
                                await markAllAsRead()
                            }
                        }
                        .foregroundColor(.blue)
                        
                        Button("Clear Read Notifications") {
                            // This would be implemented to remove read notifications
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Debug info (only in debug builds)
                #if DEBUG
                Section("Debug Info") {
                    LabeledContent("Unread Count", value: "\(notificationsStore.unreadCount)")
                    LabeledContent("Total Notifications", value: "\(notificationsStore.notifications.count)")
                    LabeledContent("Current Filter", value: notificationsStore.currentFilter.displayName)
                }
                #endif
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
            .onChange(of: enableNotifications) { _, newValue in
                if !newValue {
                    // Disable all sub-settings when main toggle is off
                    enableMentions = false
                    enableAssignments = false
                    enableBuildFailures = false
                    enableApprovalRequests = false
                    enablePushNotifications = false
                    enableEmailNotifications = false
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadCurrentSettings() {
        // In a real app, you'd load these from UserDefaults or a backend
        // For now, we'll use default values
        enableNotifications = true
        enableMentions = true
        enableAssignments = true
        enableBuildFailures = true
        enableApprovalRequests = true
        enablePushNotifications = true
        enableEmailNotifications = false
    }
    
    private func markAllAsRead() async {
        let unreadNotifications = notificationsStore.notifications.filter { $0.isUnread }
        
        await withTaskGroup(of: Void.self) { group in
            for notification in unreadNotifications {
                group.addTask {
                    await notificationsStore.markAsDone(notification)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct NotificationTypeRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}

#Preview {
    NotificationSettingsView()
        .environment(NotificationsStore())
        .environment(AuthenticationStore())
} 
