# GitLabExplorer

**GitLabExplorer** - A native iOS app for exploring GitLab repositories, users, and projects with real-time notifications and OAuth authentication using GraphQL.

## Key Features

🔐 **Secure Authentication** - OAuth 2.0 + PKCE flow with secure keychain token storage and certificate pinning  
📱 **Native iOS Experience** - Built with SwiftUI and modern iOS design patterns  
🔔 **Real-time Notifications** - Background sync with badge counts and push notifications  
🔍 **Project Discovery** - Browse repositories, users, and groups with search functionality  
⚡ **GraphQL-Only API** - Exclusively uses GitLab's GraphQL API with type-safe operations  
🏗️ **Clean Architecture** - Modular design with separate network layer and business logic  

## Tech Stack

- **Frontend**: SwiftUI, iOS 17+, Kingfisher for optimized image loading
- **API**: GitLab GraphQL API exclusively (no REST endpoints)
- **Networking**: Apollo GraphQL client with generated type-safe operations and TLS certificate pinning
- **Authentication**: OAuth 2.0 + PKCE with KeychainAccess
- **Architecture**: MVVM with Observable state management
- **Concurrency**: Swift 6 async/await with Sendable compliance

## Project Structure

The app features a modular architecture with:
- **Features**: Home, Projects, Users, Notifications, Account views
- **Core**: Authentication, configuration, and service layers
- **GitLabNetwork Package**: Reusable GraphQL client with OAuth support

Built exclusively on GitLab's GraphQL API for modern, efficient data fetching and real-time updates. Perfect for developers who want to explore GitLab projects on the go with a native iOS experience! 🚀