# Certificate Pinning for GitLab GraphQL API

This implementation provides **certificate pinning** for the GitLab GraphQL API using Network Framework and URLSession.

## 🔐 What is Certificate Pinning?

Certificate pinning is a security technique that ensures your app only accepts connections from servers with specific SSL certificates. This prevents:

- **Man-in-the-Middle (MITM) attacks**
- **Certificate authority (CA) compromises**
- **DNS hijacking**
- **Rogue certificates**

## 🏗️ Implementation Details

### Modern Best Practices

✅ **Network Framework** - Uses the recommended networking stack  
✅ **URLSession with Delegate** - Proper certificate validation  
✅ **Public Key Pinning** - More flexible than certificate pinning  
✅ **SHA-256 Hashing** - Industry standard cryptographic hashing  
✅ **Error Handling** - Comprehensive error types and messages  
✅ **Debug/Release Modes** - Different behavior for development vs production  

### Security Features

- **Public Key Pinning**: Pins the server's public key hash instead of the full certificate
- **Certificate Chain Validation**: Validates the entire certificate chain
- **Hostname Verification**: Ensures the certificate matches the expected hostname
- **Graceful Degradation**: In debug mode, allows requests to continue for development

## 📁 Files

### Core Implementation
- `CertificatePinning.swift` - Main certificate pinning logic
- `GraphQLClient.swift` - Updated to use pinned URLSession

### Utilities
- `get-gitlab-cert-hashes.sh` - Script to extract certificate hashes

## 🔧 How to Use

### 1. Certificate Hash Extraction

Run the script to get current GitLab certificate hashes:

```bash
./Scripts/get-gitlab-cert-hashes.sh
```

### 2. Update Certificate Hashes

Replace the hashes in `CertificatePinning.swift`:

```swift
private static let gitlabPublicKeyHashes: Set<String> = [
    "sha256//7wkd0YUvyMiF/H74I7FLGYVcIsb8eFDhjA8Aqq0S2+U="
]
```

### 3. Automatic Integration

The GraphQLClient automatically uses certificate pinning:

```swift
let client = GraphQLClient(configuration: config, authProvider: authProvider)
// Certificate pinning is automatically applied
```

## 🚨 Certificate Rotation

When GitLab rotates their SSL certificates:

1. **Run the hash extraction script**:
   ```bash
   ./Scripts/get-gitlab-cert-hashes.sh
   ```

2. **Update the hashes** in `CertificatePinning.swift`

3. **Test the connection** to ensure it works

4. **Deploy the update** before the old certificate expires

## 🔍 Error Handling

The implementation provides detailed error types:

- `trustEvaluationFailed` - System trust evaluation failed
- `certificateNotTrusted` - Certificate not trusted by system
- `certificateNotPinned` - Certificate doesn't match pinned hashes
- `publicKeyExtractionFailed` - Failed to extract public key

## 🛡️ Security Considerations

### Production vs Development

- **Production**: Strict certificate pinning - fails on mismatch
- **Development**: Graceful degradation - allows requests to continue

### Backup Certificates

- Include backup certificate hashes for certificate rotation
- Monitor certificate expiration dates
- Have a plan for emergency certificate updates

### Network Security

- Certificate pinning works alongside other security measures
- Combines with TLS 1.3 for maximum security
- Protects against CA compromise scenarios

## 📊 Benefits

✅ **Prevents MITM attacks**  
✅ **Protects against CA compromises**  
✅ **Ensures connection authenticity**  
✅ **Complies with security best practices**  
✅ **Uses Apple's recommended approach**  
✅ **Easy to maintain and update**  

## 🔄 Maintenance

### Regular Tasks

1. **Monitor certificate expiration** (GitLab certificates typically last 1-2 years)
2. **Run hash extraction script** quarterly to check for changes
3. **Update hashes** when GitLab rotates certificates
4. **Test connections** after any updates

### Emergency Procedures

If certificate pinning breaks:

1. **Check if GitLab rotated certificates**
2. **Extract new hashes immediately**
3. **Update and deploy quickly**
4. **Consider temporary fallback** if needed

## 📚 References

- [Apple Network Framework Documentation](https://developer.apple.com/documentation/network)
- [OWASP Certificate Pinning Guide](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [GitLab SSL Certificate Information](https://gitlab.com/help/user/gitlab_com/index.md#ssl-certificates) 