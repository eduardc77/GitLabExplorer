//
//  ContentView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct ContentView: View {
    @Environment(NotificationsStore.self) private var notificationsStore
    @State private var homeCoordinator = HomeCoordinator()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
                .badge(notificationsStore.unreadCount)
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Account")
            }
        }
        .environment(homeCoordinator)
    }
}

// MARK: - Account Button

struct AccountButton: View {
    @Environment(AuthenticationStore.self) private var authStore
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if let user = authStore.currentUser {
                    // Show user avatar when authenticated
                    AvatarView(
                        imageURL: user.avatarUrl,
                        size: 28,
                        placeholder: String(user.name.prefix(1))
                    )
                } else {
                    // Show generic icon when not authenticated
                    Image(systemName: authStore.isAuthenticated ? "person.crop.circle.fill" : "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(authStore.isAuthenticated ? .blue : .primary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthenticationStore())
}
