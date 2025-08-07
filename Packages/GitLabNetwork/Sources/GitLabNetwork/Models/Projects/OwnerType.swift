public enum OwnerType: String, Sendable, Codable, CaseIterable, Hashable {
    case user = "User"
    case group = "Group"
    case organization = "Organization"
}
