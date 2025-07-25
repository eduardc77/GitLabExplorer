//
//  GitLabConfiguration.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import GitLabNetwork

extension GitLabConfiguration {
    
    /// Initialize GitLab configuration from Info.plist
    /// This follows Apple's recommended approach for app configuration
    static func fromInfoPlist() -> GitLabConfiguration {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let gitlabConfig = plist["GitLabConfiguration"] as? [String: Any],
              let baseURLString = gitlabConfig["BaseURL"] as? String,
              let baseURL = URL(string: baseURLString),
              let clientID = gitlabConfig["ClientID"] as? String,
              let redirectURI = gitlabConfig["RedirectURI"] as? String else {
            fatalError("GitLabConfiguration not found or invalid in Info.plist")
        }
        
        return GitLabConfiguration(
            baseURL: baseURL,
            clientID: clientID,
            redirectURI: redirectURI
        )
    }
    
    /// Preview configuration for SwiftUI previews
    static func preview() -> GitLabConfiguration {
        return GitLabConfiguration(
            baseURL: URL(string: "https://gitlab.com")!,
            clientID: "preview-client-id",
            redirectURI: "gitlabexplorer://auth/callback"
        )
    }
} 
