//
//  ActivityRowView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ActivityRowView: View {
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(.gray.gradient)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "person")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Someone pushed to awesome-project")
                    .font(.subheadline)
                Text("\(index + 1) hour ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ActivityRowView(index: 2)
}
