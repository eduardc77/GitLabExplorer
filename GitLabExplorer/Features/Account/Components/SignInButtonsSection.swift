//
//  SignInButtonsSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct SignInButtonsSection: View {
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        Section {
            VStack(spacing: 12) {
                Button {
                    Task {
                        await authStore.signIn()
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.badge.key")
                        Text("Sign in with GitLab")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .cornerRadius(12)
                }
                .disabled(authStore.isAuthenticating)
            }
        }
    }
}

#Preview {
    SignInButtonsSection()
        .environment(AuthenticationStore())
        .padding()
}
