//
//  ExploreView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ExploreView: View {
    @Binding var showingAccountSheet: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    TrendingSection()
                    Divider()
                        .padding(.horizontal)
                    RecentActivitySection()
                }
                .padding(.top)
            }
            .navigationTitle("Explore")
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
        }
    }
}

#Preview {
    ExploreView(showingAccountSheet: .constant(false))
}
