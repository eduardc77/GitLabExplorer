#!/bin/bash
set -e

echo "🚀 Apollo iOS Code Generation"
echo "📍 SRCROOT: ${SRCROOT}"
echo "📍 PROJECT_DIR: ${PROJECT_DIR}"
echo "📍 PWD: $(pwd)"

# Check if we're in a CI environment
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$RUNNER_OS" ]; then
    echo "⏭️  Skipping Apollo Code Generation in CI environment"
    echo "📝 CI detected: CI=$CI, GITHUB_ACTIONS=$GITHUB_ACTIONS, RUNNER_OS=$RUNNER_OS"
    exit 0
fi

# Try multiple possible paths for GitLabNetwork
POSSIBLE_PATHS=(
    "${SRCROOT}/Packages/GitLabNetwork"
    "${PROJECT_DIR}/Packages/GitLabNetwork"
    "${SRCROOT}/../Packages/GitLabNetwork"
    "$(pwd)/Packages/GitLabNetwork"
    "./Packages/GitLabNetwork"
)

GITLAB_NETWORK_DIR=""

for path in "${POSSIBLE_PATHS[@]}"; do
    echo "🔍 Checking path: $path"
    if [ -d "$path" ]; then
        GITLAB_NETWORK_DIR="$path"
        echo "✅ Found GitLabNetwork at: $GITLAB_NETWORK_DIR"
        break
    fi
done

if [ -z "$GITLAB_NETWORK_DIR" ]; then
    echo "❌ Error: GitLabNetwork package not found in any of these locations:"
    for path in "${POSSIBLE_PATHS[@]}"; do
        echo "   - $path"
    done
    
    echo ""
    echo "📂 Current working directory contents:"
    ls -la
    
    echo ""
    echo "📂 SRCROOT contents:"
    ls -la "${SRCROOT}" || echo "SRCROOT not accessible"
    
    exit 1
fi

cd "$GITLAB_NETWORK_DIR"
echo "📂 Changed to directory: $(pwd)"

# List contents to verify we're in the right place
echo "📂 Contents of GitLabNetwork directory:"
ls -la

# Check if apollo-ios-cli exists
if [ ! -f "./apollo-ios-cli" ]; then
    echo "❌ Error: apollo-ios-cli not found."
    echo "🔧 Attempting to extract CLI from Apollo package..."
    
    # Try to extract CLI from Apollo package
    if [ -f ".build/checkouts/apollo-ios/CLI/apollo-ios-cli.tar.gz" ]; then
        echo "📦 Extracting Apollo CLI..."
        cd .build/checkouts/apollo-ios/CLI
        tar -xf apollo-ios-cli.tar.gz
        cp apollo-ios-cli "../../../../"
        cd ../../../
        echo "✅ Apollo CLI extracted successfully"
    else
        echo "❌ Error: Apollo CLI not found. Please run 'swift build' first to download dependencies."
        exit 1
    fi
fi

# Check if configuration file exists
if [ ! -f "./apollo-codegen-config.json" ]; then
    echo "❌ Error: apollo-codegen-config.json not found"
    echo "📂 Current directory contents:"
    ls -la
    exit 1
fi

echo "✅ Found apollo-codegen-config.json"

# Only run in Debug configuration to avoid slowing down Release builds
if [ "${CONFIGURATION}" = "Debug" ]; then
    echo "🔄 Running Apollo Code Generation..."
    ./apollo-ios-cli generate
    echo "✅ Apollo Code Generation completed successfully!"
else
    echo "⏭️  Skipping Apollo Code Generation in ${CONFIGURATION} configuration"
fi 