//
//  AccountCoordinator.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import SwiftUI
import GitLabNetwork

@Observable
final class AccountCoordinator {
    var navigationPath = NavigationPath()
    
    enum Destination: Hashable {
        case personalProjects
        case groups
        case assignedIssues
        case mergeRequests
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
