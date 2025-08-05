import Foundation

public struct LicenseInfo: Sendable, Codable, Equatable {
    public let name: String
    public let key: String?
    public let url: URL?
    
    public init(name: String, key: String?, url: URL?) {
        self.name = name
        self.key = key
        self.url = url
    }
}
