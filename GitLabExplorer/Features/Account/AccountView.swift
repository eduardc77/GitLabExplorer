//
//  AccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationStore.self) private var authStore
    
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
 
