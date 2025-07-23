# GitLabNetwork Architecture

## Package Structure

GitLabNetwork/Sources/GitLabNetwork/
├── Models/
│   ├── GitLabUser.swift         // User domain model + Apollo conversions
│   ├── GitLabProject.swift      // Project domain model
│   ├── GitLabNotification.swift // Notification domain model
│   ├── GitLabConfiguration.swift // API configuration
│   ├── GitLabError.swift        // Error types
│   └── OAuthToken.swift         // OAuth token model
├── Services/
│   ├── UserService.swift       // User business logic (Sendable)
│   ├── ProjectService.swift    // Project business logic (Sendable)
│   └── NotificationService.swift // Notification business logic (Sendable)
├── Auth/
│   ├── AuthenticationManager.swift // Auth state (@Observable)
│   ├── TokenManager.swift         // Token persistence
│   ├── OAuthClient.swift          // OAuth flow
│   └── GitLabAuthProvider.swift   // Apollo auth integration
└── GraphQL/
    ├── ModernApolloClient.swift   // Apollo configuration
    ├── ApolloAsyncExtensions.swift // Swift concurrency extensions
    └── Generated/                 // Apollo codegen output
```

## Component Responsibilities

### Models
- Pure domain objects representing GitLab entities
- Apollo GraphQL conversion methods
- No business logic or UI concerns

### Services  
- Pure business logic operations
- Marked as `Sendable` for concurrency safety
- No UI state or caching responsibilities
- Focused on network operations and data transformation

### Auth
- OAuth 2.0 + PKCE authentication flow
- Secure token storage using Keychain
- Authentication state management for UI binding
- Apollo client authentication integration

### GraphQL
- Apollo client configuration and setup
- Swift concurrency extensions for async/await
- Generated type-safe GraphQL operations

## Design Principles Applied

- **Single Responsibility**: Each file has one clear purpose
- **Separation of Concerns**: Business logic, models, and auth are separate
- **Sendable Compliance**: Services work safely across actor boundaries  
- **Observable Integration**: Auth manager provides reactive state for UI

## Dependencies

- **Apollo iOS**: GraphQL client and code generation
- **KeychainAccess**: Secure credential storage 
