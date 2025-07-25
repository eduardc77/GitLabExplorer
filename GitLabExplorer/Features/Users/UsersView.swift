//
//  UsersView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct UsersView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<10, id: \.self) { index in
                    UserRowView(index: index)
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.large)

            .searchable(text: $searchText, prompt: "Search users...")
            .refreshable {
                // TODO: Refresh users
            }
        }
    }
}

#Preview {
    UsersView()
        .environment(AuthenticationStore())
}
