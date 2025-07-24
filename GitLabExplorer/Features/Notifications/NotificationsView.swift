import SwiftUI
import GitLabNetwork

struct NotificationsView: View {
    @Environment(NotificationsStore.self) private var notificationsStore
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        NavigationStack {
            Group {
                if !authStore.isAuthenticated {
                    UnauthenticatedNotificationsView()
                } else if notificationsStore.isEmpty && !notificationsStore.isLoading {
                    EmptyNotificationsView()
                } else {
                    NotificationsList()
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        FilterMenu()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await notificationsStore.refresh()
            }
            .task {
                if authStore.isAuthenticated && notificationsStore.notifications.isEmpty {
                    await notificationsStore.loadNotifications(refresh: true)
                }
            }
        }
    }
}

// MARK: - Authenticated Content

private struct NotificationsList: View {
    @Environment(NotificationsStore.self) private var store
    
    var body: some View {
        List {
            if store.unreadCount > 0 {
                Section {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.blue)
                        Text("\(store.unreadCount) unread notifications")
                            .font(.subheadline)
                        Spacer()
                        Button("Mark All Read") {
                            Task {
                                await markAllAsRead()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section {
                ForEach(store.displayedNotifications) { notification in
                    NotificationRowView(notification: notification)
                        .onTapGesture {
                            Task {
                                await store.markAsDone(notification)
                            }
                        }
                }
                
                if store.hasNextPage && !store.isLoading {
                    LoadMoreButton()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .overlay {
            if store.isLoading && store.notifications.isEmpty {
                ProgressView("Loading notifications...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    private func markAllAsRead() async {
        let pendingNotifications = store.notifications.filter { $0.isUnread }
        await withTaskGroup(of: Void.self) { group in
            for notification in pendingNotifications {
                group.addTask {
                    await store.markAsDone(notification)
                }
            }
        }
    }
}

private struct LoadMoreButton: View {
    @Environment(NotificationsStore.self) private var store
    
    var body: some View {
        HStack {
            Spacer()
            if store.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button("Load More") {
                    Task {
                        await store.loadMoreNotifications()
                    }
                }
                .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Menu

private struct FilterMenu: View {
    @Environment(NotificationsStore.self) private var store
    
    var body: some View {
        ForEach(NotificationFilter.allCases, id: \.self) { filter in
            Button {
                Task {
                    await store.changeFilter(to: filter)
                }
            } label: {
                HStack {
                    Text(filter.displayName)
                    if store.currentFilter == filter {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

// MARK: - Empty States

private struct EmptyNotificationsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Notifications", systemImage: "bell.slash")
        } description: {
            Text("You're all caught up! New notifications will appear here.")
        }
    }
}

private struct UnauthenticatedNotificationsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Sign In Required", systemImage: "person.crop.circle.badge.questionmark")
        } description: {
            Text("Sign in to view your GitLab notifications and stay updated with your projects.")
        } actions: {
            NavigationLink("Go to Account") {
                AccountView()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NotificationsView()
        .environment(NotificationsStore(
            notificationService: NotificationService(
                graphQLClient: GraphQLClient(
                    configuration: GitLabConfiguration(
                        baseURL: URL(string: "https://gitlab.com")!,
                        clientID: "test",
                        redirectURI: "test://callback"
                    ),
                    authProvider: GitLabAuthProvider(
                        tokenManager: TokenManager(
                            configuration: GitLabConfiguration(
                                baseURL: URL(string: "https://gitlab.com")!,
                                clientID: "test", 
                                redirectURI: "test://callback"
                            )
                        )
                    )
                ),
                authService: AuthenticationService(
                    configuration: GitLabConfiguration(
                        baseURL: URL(string: "https://gitlab.com")!,
                        clientID: "test",
                        redirectURI: "test://callback"
                    ),
                    graphQLClient: GraphQLClient(
                        configuration: GitLabConfiguration(
                            baseURL: URL(string: "https://gitlab.com")!,
                            clientID: "test",
                            redirectURI: "test://callback"
                        ),
                        authProvider: GitLabAuthProvider(
                            tokenManager: TokenManager(
                                configuration: GitLabConfiguration(
                                    baseURL: URL(string: "https://gitlab.com")!,
                                    clientID: "test",
                                    redirectURI: "test://callback"
                                )
                            )
                        )
                    )
                )
            ),
            authStore: AuthenticationStore()
        ))
        .environment(AuthenticationStore())
} 