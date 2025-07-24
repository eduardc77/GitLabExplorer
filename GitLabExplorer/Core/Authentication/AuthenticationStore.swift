import SwiftUI
import GitLabNetwork
import AuthenticationServices

/// Main authentication store for the app
@MainActor
@Observable
final class AuthenticationStore: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let authService: AuthenticationService
    private let configuration: GitLabConfiguration

    private(set) var isAuthenticated = false
    private(set) var currentUser: GitLabUser?

    private(set) var isAuthenticating = false
    private(set) var isLoadingUser = false

    private(set) var authError: GitLabError?

    override init() {
        self.configuration = GitLabConfiguration(
            baseURL: URL(string: "https://gitlab.com")!,
            clientID: "4e130d01a21e737b17beb754b61d3018831b5c564069e649375761dd9d772b7e",
            redirectURI: "gitlabexplorer://auth/callback"
        )
        
        // Create shared GraphQL client
        let tokenManager = TokenManager(configuration: configuration)
        let authProvider = GitLabAuthProvider(tokenManager: tokenManager)
        let graphQLClient = GraphQLClient(configuration: configuration, authProvider: authProvider)
        
        // Initialize auth service
        self.authService = AuthenticationService(
            configuration: configuration,
            graphQLClient: graphQLClient
        )
        
        super.init()
        
        // Set up initial state
        Task {
            await refreshAuthState()
        }
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
    
                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = true  // Use private session - no remembered login
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

    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Use your cleaner approach here
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
