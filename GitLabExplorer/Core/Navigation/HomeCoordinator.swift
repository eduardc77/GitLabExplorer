//
//  HomeCoordinator.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

@Observable
final class HomeCoordinator {
    var navigationPath = NavigationPath()
    
    enum Destination: Hashable {
        case projects
        case users
        case groups
        case topics
        case projectDetail(ProjectSummary)
        case userDetail(GitLabUser)
    }

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
} 
