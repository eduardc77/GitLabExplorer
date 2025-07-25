//
//  ProjectsView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ProjectsView: View {
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<10, id: \.self) { index in
                    ProjectRowView(index: index)
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)

            .refreshable {
                // TODO: Refresh projects
            }
        }
    }
}

#Preview {
    ProjectsView()
        .environment(AuthenticationStore())
}
