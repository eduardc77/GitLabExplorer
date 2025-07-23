//
//  RecentActivitySection.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(0..<8, id: \.self) { index in
                    ActivityRowView(index: index)
                }
            }
        }
    }
}

#Preview {
    RecentActivitySection()
}
