//
//  AccountSettingsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountSettingsView: View {
    var body: some View {
        SettingsView()
    }
}

#Preview {
    AccountSettingsView()
        .environment(AuthenticationStore())
} 
