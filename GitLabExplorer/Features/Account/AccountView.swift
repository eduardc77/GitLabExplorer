//
//  AccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if authStore.isAuthenticated {
                    AuthenticatedAccountView()
                } else {
                    UnauthenticatedAccountView()
                }
            }
            .navigationTitle("Account")
            .toolbar {
                if authStore.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                AccountSettingsView()
            }
            .alert("Authentication Error", isPresented: .constant(authStore.authError != nil)) {
                Button("OK") {
                    authStore.clearError()
                }
            } message: {
                if let error = authStore.authError {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthenticationStore())
}
 
