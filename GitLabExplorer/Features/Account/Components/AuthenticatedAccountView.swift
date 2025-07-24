//
//  AuthenticatedAccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AuthenticatedAccountView: View {
    var body: some View {
        Form {
            UserProfileSection()
            AccountSettingsSection()
            SignOutSection()
        }
    }
}

#Preview {
    AuthenticatedAccountView()
        .environment(AuthenticationStore())
}
