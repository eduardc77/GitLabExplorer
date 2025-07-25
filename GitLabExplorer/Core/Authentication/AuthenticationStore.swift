//
//  AuthenticationStore.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import GitLabNetwork
import AuthenticationServices

/// Main authentication store for the app
@MainActor
@Observable
public final class AuthenticationStore {
    private let authService: AuthenticationService
    private let configuration: GitLabConfiguration

    private(set) var isAuthenticated = false
    private(set) var currentUser: GitLabUser?

    private(set) var isAuthenticating = false
    private(set) var isLoadingUser = false

    private(set) var authError: GitLabError?

    public init(authService: AuthenticationService, configuration: GitLabConfiguration) {
        self.authService = authService
        self.configuration = configuration
        
        // Set up initial state
        Task {
            await refreshAuthState()
        }
    }

    /// Convenience initializer for SwiftUI previews
    public convenience init() {
        let configuration = GitLabConfiguration.preview()
        
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        let authService = AuthenticationService(configuration: configuration, graphQLClient: graphQLClient)
        
        self.init(authService: authService, configuration: configuration)
    }
    
    // MARK: - Authentication Actions
    
    /// Start OAuth authentication flow
    func signIn() async {
        isAuthenticating = true
        authError = nil
        
        do {
            // Get OAuth URL from service
            let authURL = try await authService.authenticate()
            
            let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
                let session = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: "gitlabexplorer"
                ) { callbackURL, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let callbackURL = callbackURL {
                        continuation.resume(returning: callbackURL)
                    } else {
                        continuation.resume(throwing: GitLabError.authorizationFailed("No callback URL"))
        }
    }
    
                session.presentationContextProvider = AuthenticationHandler.shared
                session.prefersEphemeralWebBrowserSession = false  // remembered login
                session.start()
            }
            
            // Handle the callback
            try await authService.handleAuthCallback(url: callbackURL)
            await refreshAuthState()
            
        } catch {
            authError = error as? GitLabError ?? GitLabError.unknown(error)
            isAuthenticating = false
        }
    }
    
    /// Sign out current user
    func signOut() async {
        do {
            try await authService.signOut()
            await refreshAuthState()
        } catch {
            authError = error as? GitLabError ?? GitLabError.unknown(error)
        }
    }
    
    /// Clear any authentication errors
    func clearError() {
        authError = nil
    }
    
    /// Refresh authentication state
    func refreshAuthState() async {
        isLoadingUser = true
        
        do {
            let authenticated = await authService.isAuthenticated
            isAuthenticated = authenticated
            
            if authenticated {
                currentUser = try await authService.getCurrentUser()
            } else {
                currentUser = nil
            }
            
            isAuthenticating = false
            isLoadingUser = false
        } catch {
            authError = error as? GitLabError ?? GitLabError.unknown(error)
            isAuthenticated = false
            currentUser = nil
            isAuthenticating = false
            isLoadingUser = false
                }
    }
}

final class AuthenticationHandler: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthenticationHandler()
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
