#!/bin/bash

echo "🔐 Extracting GitLab SSL Certificate Public Key Hashes"
echo "======================================================"

# Function to get certificate hash for a domain
get_cert_hash() {
    local domain=$1
    echo "📋 Getting certificate hash for: $domain"
    
    # Get the certificate and extract the public key hash
    local hash=$(echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null | \
                 openssl x509 -pubkey -noout 2>/dev/null | \
                 openssl pkey -pubin -outform DER 2>/dev/null | \
                 openssl dgst -sha256 -binary 2>/dev/null | \
                 base64 2>/dev/null)
    
    if [ -n "$hash" ]; then
        echo "✅ $domain: sha256//$hash"
        echo "   Use this in CertificatePinning.swift"
    else
        echo "❌ Failed to get certificate hash for $domain"
    fi
    echo ""
}

# Get hashes for GitLab domains
echo "🌐 GitLab.com certificate hash:"
get_cert_hash "gitlab.com"

echo "🏢 GitLab.com (with www) certificate hash:"
get_cert_hash "www.gitlab.com"

echo "📝 Instructions:"
echo "1. Copy the hash values above"
echo "2. Replace the placeholder values in CertificatePinning.swift"
echo "3. Update the gitlabPublicKeyHashes set with the actual hashes"
echo ""
echo "Example:"
echo "private static let gitlabPublicKeyHashes: Set<String> = ["
echo "    \"sha256//ACTUAL_HASH_HERE\","
echo "    \"sha256//BACKUP_HASH_HERE\""
echo "]" 