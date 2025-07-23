//
//  TrendingSection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct TrendingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame")
                    .foregroundColor(.orange)
                Text("Trending This Week")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { index in
                        TrendingProjectCard(index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    TrendingSection()
}
