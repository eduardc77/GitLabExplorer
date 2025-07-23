# GitLabNetwork

A GitLab GraphQL API client package for Swift.

## What's Included

### Features
- OAuth 2.0 + PKCE authentication
- Apollo GraphQL client integration
- Swift 6 concurrency support
- Secure keychain token storage
- Type-safe GraphQL operations

### Package Contents

**Models/**
- Domain models for GitLab entities (User, Project, Notification)
- Apollo GraphQL conversion extensions
- Configuration and error types
- OAuth token models

**Services/**
- Pure business logic services (`Sendable`)
- User operations (search, profile)
- Project operations 
- Notification operations

**Auth/**
- OAuth 2.0 + PKCE flow implementation
- Token management with keychain storage
- Authentication state management (`@Observable`)
- Apollo authentication provider

**GraphQL/**
- Apollo client configuration
- Generated type-safe operations
- Async/await extensions for Swift concurrency

## Dependencies

- Apollo iOS (GraphQL client)
- KeychainAccess (secure storage)

## License

MIT 