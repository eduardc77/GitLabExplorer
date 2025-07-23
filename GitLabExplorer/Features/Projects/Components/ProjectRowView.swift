//
//  ProjectRowView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ProjectRowView: View {
    let index: Int
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.gradient)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "folder")
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Project \(index + 1)")
                    .font(.headline)
                Text("Public • 12 stars • Updated 2 days ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProjectRowView(index: 0)
        .padding()
}
