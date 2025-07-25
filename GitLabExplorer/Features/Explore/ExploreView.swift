//
//  ExploreView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ExploreView: View {
    
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

        }
    }
}

#Preview {
    ExploreView()
        .environment(AuthenticationStore())
}
