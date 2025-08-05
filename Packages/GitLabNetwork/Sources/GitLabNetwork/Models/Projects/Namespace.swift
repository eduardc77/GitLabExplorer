/// GitLab namespace (group or user) information
public struct Namespace: Sendable, Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let path: String
    public let fullPath: String
    
    public init(id: String, name: String, path: String, fullPath: String) {
        self.id = id
        self.name = name
        self.path = path
        self.fullPath = fullPath
    }
} 
