//
//  SignInButtonsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct SignInButtonsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Button {
                // TODO: Implement authentication
                print("Starting GitLab authentication...")
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

            Button {
                // TODO: Learn more about the app
            } label: {
                Text("Learn more about GitLab Explorer")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignInButtonsView()
        .padding()
}
