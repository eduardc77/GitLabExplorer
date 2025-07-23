//
//  UsersView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct UsersView: View {
    @Binding var showingAccountSheet: Bool
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAccountSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search users...")
            .refreshable {
                // TODO: Refresh users
            }
        }
    }
}

#Preview {
    UsersView(showingAccountSheet: .constant(false))
}
