//
//  AccountFooterView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct AccountFooterView: View {
    var body: some View {
        Text("By signing in, you agree to our Terms of Service and Privacy Policy")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

#Preview {
    AccountFooterView()
        .padding()
}
