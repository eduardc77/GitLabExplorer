public struct ProjectLanguage: Sendable, Codable, Equatable {
    public let name: String
    public let percentage: Double
    public let color: String?
    
    public init(name: String, percentage: Double, color: String? = nil) {
        self.name = name
        self.percentage = percentage
        self.color = color
    }
}
