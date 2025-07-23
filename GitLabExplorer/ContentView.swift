//
//  ContentView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingAccountSheet = false
    
    var body: some View {
        TabView {
            ProjectsView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "folder")
                    Text("Projects")
                }
            
            UsersView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Users")
                }
            
            ExploreView(showingAccountSheet: $showingAccountSheet)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
        }
        .sheet(isPresented: $showingAccountSheet) {
            AccountView()
        }
    }
}

#Preview {
    ContentView()
}
