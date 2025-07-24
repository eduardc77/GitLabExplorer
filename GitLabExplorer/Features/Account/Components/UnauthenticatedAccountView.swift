//
//  UnauthenticatedAccountView.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI

struct UnauthenticatedAccountView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App Icon/Logo area
            VStack(spacing: 16) {
                Image(systemName: "cube.box")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("GitLab Explorer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Explore GitLab projects, users, and more")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Sign in section
            SignInButtonsSection()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    UnauthenticatedAccountView()
} 
