//
//  ContentView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

struct ContentView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(NotificationsStore.self) private var notificationsStore
    @State private var showingAccountSheet = false

    var body: some View {
        TabView {
            ProjectsView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "folder")
                    Text("Projects")
                }

            UsersView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Users")
                }

            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
                .badge(notificationsStore.unreadCount)

            ExploreView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
        }
        .sheet(isPresented: $showingAccountSheet) {
            AccountView()
        }
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
                    AsyncImage(url: user.avatarUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(.blue.gradient)
                            .overlay {
                                Text(String(user.name.prefix(1)))
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
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
