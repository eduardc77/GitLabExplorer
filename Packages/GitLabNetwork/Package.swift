// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabNetwork",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GitLabNetwork",
            targets: ["GitLabNetwork"]),
    ],
    dependencies: [
        // Apollo GraphQL dependencies
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "1.0.0")),
        // Keychain access for secure token storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "GitLabNetwork",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ],
            resources: [
                .copy("GraphQL/Operations"),
                .copy("GraphQL/schema.json")
            ]
        ),
        .testTarget(
            name: "GitLabNetworkTests",
            dependencies: ["GitLabNetwork"]),
    ]
)
