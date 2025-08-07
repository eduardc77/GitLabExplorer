import Foundation
import Network
import Security
import CommonCrypto

/// Certificate pinning configuration for GitLab GraphQL API
public struct CertificatePinning {
    
    /// GitLab's SSL certificate public key hashes (SHA-256)
    /// These are the public key hashes of GitLab's SSL certificates
    /// Extracted using: ./Scripts/get-gitlab-cert-hashes.sh
    static let gitlabPublicKeyHashes: Set<String> = [
        // GitLab's current SSL certificate public key hash
        "sha256//7wkd0YUvyMiF/H74I7FLGYVcIsb8eFDhjA8Aqq0S2+U="
        // Add backup certificate hash here when GitLab rotates certificates
    ]
    
    /// Creates a URLSession with certificate pinning for GitLab API
    public static func createPinnedURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        let delegate = CertificatePinningDelegate()
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

// MARK: - Certificate Pinning Delegate

/// URLSession delegate that implements certificate pinning
private final class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Verify the server trust
        let result = verifyServerTrust(serverTrust, for: challenge.protectionSpace.host)
        
        switch result {
        case .success:
            // Certificate is valid and pinned
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            
        case .failure(let error):
            print("Certificate pinning failed: \(error)")
            // In production, you might want to fail the request
            // For development, you can allow the request to continue
            #if DEBUG
            completionHandler(.performDefaultHandling, nil)
            #else
            completionHandler(.cancelAuthenticationChallenge, nil)
            #endif
        }
    }
    
    /// Verify server trust against pinned certificates
    private func verifyServerTrust(_ serverTrust: SecTrust, for host: String) -> Result<Void, CertificatePinningError> {
        // Evaluate the trust using modern API
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
        
        guard isValid else {
            return .failure(.trustEvaluationFailed(errSecSuccess))
        }
        
        // Extract the certificate chain
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0 else {
            return .failure(.noCertificatesFound)
        }
        
        // Get the leaf certificate (first in the chain)
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = certificateChain.first else {
            return .failure(.certificateExtractionFailed)
        }
        
        // Extract the public key from the certificate
        guard let publicKey = SecCertificateCopyKey(certificate) else {
            return .failure(.publicKeyExtractionFailed)
        }
        
        // Get the public key data using modern API
        var keyError: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &keyError) as Data? else {
            return .failure(.publicKeyDataExtractionFailed)
        }
        
        // Calculate the SHA-256 hash of the public key
        let hash = keyData.sha256()
        let hashString = "sha256//\(hash.base64EncodedString())"
        
        // Check if the hash matches our pinned certificates
        guard CertificatePinning.gitlabPublicKeyHashes.contains(hashString) else {
            return .failure(.certificateNotPinned(hashString))
        }
        
        return .success(())
    }
}

// MARK: - Certificate Pinning Errors

/// Errors that can occur during certificate pinning
public enum CertificatePinningError: LocalizedError {
    case trustEvaluationFailed(OSStatus)
    case certificateNotTrusted(SecTrustResultType)
    case noCertificatesFound
    case certificateExtractionFailed
    case publicKeyExtractionFailed
    case publicKeyDataExtractionFailed
    case certificateNotPinned(String)
    
    public var errorDescription: String? {
        switch self {
        case .trustEvaluationFailed(let status):
            return "Trust evaluation failed with status: \(status)"
        case .certificateNotTrusted(let result):
            return "Certificate not trusted: \(result)"
        case .noCertificatesFound:
            return "No certificates found in the certificate chain"
        case .certificateExtractionFailed:
            return "Failed to extract certificate from trust"
        case .publicKeyExtractionFailed:
            return "Failed to extract public key from certificate"
        case .publicKeyDataExtractionFailed:
            return "Failed to extract public key data"
        case .certificateNotPinned(let hash):
            return "Certificate not pinned. Hash: \(hash)"
        }
    }
}

// MARK: - Data Extension for SHA-256

private extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
} 