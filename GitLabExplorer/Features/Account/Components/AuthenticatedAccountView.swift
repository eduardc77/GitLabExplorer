//
//  AuthenticatedAccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AuthenticatedAccountView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                UserProfileSection()
                YourWorkSection()
            }
            .padding()
        }
    }
}

#Preview {
    AuthenticatedAccountView()
        .environment(AuthenticationStore())
}
