//
//  TrendingProjectCard.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct TrendingProjectCard: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.purple.gradient)
                .frame(width: 120, height: 80)
                .overlay {
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            
            Text("Hot Project \(index + 1)")
                .font(.caption)
                .fontWeight(.medium)
            
            Text("1.2k ⭐")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

#Preview {
    TrendingProjectCard(index: 2)
}
