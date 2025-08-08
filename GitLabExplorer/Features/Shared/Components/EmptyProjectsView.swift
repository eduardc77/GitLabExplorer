//
//  EmptyProjectsView.swift
//  GitLabExplorer
//
//  Created by User on 8/8/25.
//

import SwiftUI

struct EmptyProjectsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Projects", systemImage: "folder.badge.questionmark")
        } description: {
            Text("No projects found. Try refreshing or check your connection.")
        }
    }
}
