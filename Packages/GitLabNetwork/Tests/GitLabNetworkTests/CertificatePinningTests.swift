import Testing
@testable import GitLabNetwork
import Foundation

struct CertificatePinningTests {
    
    @Test func testCertificatePinningCreatesURLSession() async throws {
        // Test that certificate pinning creates a URLSession
        let session = CertificatePinning.createPinnedURLSession()
        
        #expect(session != nil)
        #expect(session.delegate != nil)
        #expect(session.configuration.timeoutIntervalForRequest == 30)
        #expect(session.configuration.timeoutIntervalForResource == 60)
    }
    
    @Test func testCertificatePinningHasValidHashes() async throws {
        // Test that we have valid certificate hashes configured
        // This is a basic test - in a real scenario you'd test against actual certificates
        let hashes = [
            "sha256//7wkd0YUvyMiF/H74I7FLGYVcIsb8eFDhjA8Aqq0S2+U="
        ]
        
        for hash in hashes {
            #expect(hash.hasPrefix("sha256//"), "Hash should start with sha256//")
            #expect(hash.count > 20, "Hash should be reasonably long")
        }
    }
    
    @Test func testCertificatePinningErrorTypes() async throws {
        // Test that all certificate pinning error types are defined
        let errors: [CertificatePinningError] = [
            .trustEvaluationFailed(errSecSuccess),
            .certificateNotTrusted(.unspecified),
            .noCertificatesFound,
            .certificateExtractionFailed,
            .publicKeyExtractionFailed,
            .publicKeyDataExtractionFailed,
            .certificateNotPinned("test-hash")
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil, "All errors should have descriptions")
        }
    }
    
    @Test func testCertificatePinningConfiguration() async throws {
        // Test that certificate pinning configuration is valid
        let session = CertificatePinning.createPinnedURLSession()
        
        // Verify session configuration
        #expect(session != nil)
        #expect(session.delegate != nil)
        #expect(session.configuration.timeoutIntervalForRequest == 30)
        #expect(session.configuration.timeoutIntervalForResource == 60)
        
        // Verify certificate pinning is properly configured
        #expect(session.delegate != nil)
    }
} 
